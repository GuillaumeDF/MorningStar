//
//  WorkoutDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

struct WorkoutDataManagerFactory: HealthDataFactoryProtocol {
    typealias HealthKitDataType = WeeklyWorkouts
    typealias CoreDataType = WeeklyWorkoutsMO
    
    static var healthKitSampleType: HKSampleType? {
        HKObjectType.workoutType()
    }
    
    static var id: HealthDataType {
        .workouts
    }
    
    static var predicateCoreData: NSPredicate? {
        nil
    }
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[WeeklyWorkouts]>>? {
        let queryDescriptor = SampleQueryDescriptor<[WeeklyWorkouts]>(
            sampleType: HKObjectType.workoutType(),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples async in
            var workoutsWithIntensity: [Workout] = []
            
            await withTaskGroup(of: Workout?.self) { group in
                for sample in samples {
                    group.addTask {
                        return await fetchDataForWorkout(healthStore: healthStore, sample: sample)
                    }
                }
                
                for await result in group {
                    if let workout = result {
                        workoutsWithIntensity.append(workout)
                    }
                }
            }
            
            return HealthDataProcessor.sortAndgroupWorkoutsByDayAndWeek(workoutsWithIntensity)
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
    
    static func fetchDataForWorkout(healthStore: HKHealthStore, sample: HKSample) async -> Workout? {
        do {
            guard let heartRateEntries = try await HeartRateDataManagerFactory.createSampleQueryManager(
                for: healthStore,
                from: sample.startDate,
                to: sample.endDate
            )?.fetchData() else {
                print("Failed to fetch heart rate data")
                return nil
            }
            
            guard let calorieEntries = try await CalorieBurnedDataManagerFactory.createSampleQueryManager(
                for: healthStore,
                from: sample.startDate,
                to: sample.endDate
            )?.fetchData() else {
                print("Failed to fetch calorie burned data")
                return nil
            }
            
            let heartRates = heartRateEntries.first?.entries ?? []
            let caloriesBurned = calorieEntries.first?.entries ?? []
            
            let workoutsWithIntensity = WorkoutIntensityAnalyzer().generateIntensityPhases(
                sample: sample,
                heartRates: heartRates,
                caloriesBurned: caloriesBurned
            )
            
            return workoutsWithIntensity
        } catch {
            print("Error during workout data fetching: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[WeeklyWorkouts]>>? {
        nil
    }
    
    static func mapHealthKitToCoreData(_ healthKitData: [WeeklyWorkouts], context: NSManagedObjectContext) -> [WeeklyWorkoutsMO] {
        var weeklyWorkoutEntries: [WeeklyWorkoutsMO] = []
        
        healthKitData.forEach { weeklyWorkout in
            let weeklyWorkoutEntity = WeeklyWorkoutsMO(context: context)
            
            weeklyWorkoutEntity.id = weeklyWorkout.id
            weeklyWorkoutEntity.startDate = weeklyWorkout.startDate
            weeklyWorkoutEntity.endDate = weeklyWorkout.endDate
            
            let dailyWorkoutEntities = weeklyWorkout.dailyWorkouts.map { dailyWorkouts in
                let dailyWorkoutEntity = DailyWorkoutsMO(context: context)
                
                dailyWorkoutEntity.id = dailyWorkouts.id
                dailyWorkoutEntity.startDate = dailyWorkouts.startDate
                dailyWorkoutEntity.endDate = dailyWorkouts.endDate
                
                let workoutEntities = dailyWorkouts.workouts.map { workout in
                    let workoutEntity = WorkoutMO(context: context)
                    
                    workoutEntity.id = workout.id
                    workoutEntity.startDate = workout.startDate
                    workoutEntity.endDate = workout.endDate
                    
                    let phaseEntries = workout.phaseEntries.map { phaseEntry in
                        let newEntry = WorkoutPhaseEntryMO(context: context)
                        
                        newEntry.id = phaseEntry.id
                        newEntry.averageHeartRate = phaseEntry.averageHeartRate
                        newEntry.caloriesBurned = phaseEntry.caloriesBurned
                        newEntry.value = Int16(phaseEntry.value.rawValue)
                        newEntry.startDate = phaseEntry.startDate
                        newEntry.endDate = phaseEntry.endDate
                        newEntry.workout = workoutEntity
                        
                        return newEntry
                    }
                    
                    workoutEntity.addToWorkoutPhaseEntries(NSOrderedSet(array: phaseEntries))
                    workoutEntity.dailyWorkouts = dailyWorkoutEntity
                    
                    return workoutEntity
                }
                
                dailyWorkoutEntity.addToWorkouts(NSOrderedSet(array: workoutEntities))
                dailyWorkoutEntity.weeklyWorkout = weeklyWorkoutEntity
                
                return dailyWorkoutEntity
            }
            weeklyWorkoutEntity.addToDailyWorkouts(NSOrderedSet(array: dailyWorkoutEntities))
            weeklyWorkoutEntries.append(weeklyWorkoutEntity)
        }
        
        return weeklyWorkoutEntries
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntry: [WeeklyWorkoutsMO]) -> [WeeklyWorkouts] {
        return coreDataEntry.map { weeklyWorkoutEntity in
            let dailyWorkoutEntries: [DailyWorkouts] = (weeklyWorkoutEntity.dailyWorkouts)?.compactMap { dailyWorkoutEntry in
                guard let dailyWorkoutEntity = dailyWorkoutEntry as? DailyWorkoutsMO else {
                    return nil
                }
                
                let workoutEntries: [Workout] = (dailyWorkoutEntity.workouts)?.compactMap { workoutEntry in
                    guard let workoutEntity = workoutEntry as? WorkoutMO else {
                        return nil
                    }
                    
                    let phaseEntries: [HealthData.WorkoutPhaseEntry] = (workoutEntity.workoutPhaseEntries)?.compactMap { phaseEntry in
                        guard let phaseEntity = phaseEntry as? WorkoutPhaseEntryMO else {
                            return nil
                        }
                        
                        return HealthData.WorkoutPhaseEntry(
                            id: phaseEntity.id ?? UUID(),
                            startDate: phaseEntity.startDate ?? Date(),
                            endDate: phaseEntity.endDate ?? Date(),
                            value: IntensityLevel(rawValue: Int(phaseEntity.value)) ?? .undetermined,
                            averageHeartRate: phaseEntity.averageHeartRate,
                            caloriesBurned: phaseEntity.caloriesBurned
                        )
                    } ?? []
                    
                    return Workout(id: workoutEntity.id ?? UUID(), phaseEntries: phaseEntries)
                } ?? []
                
                return DailyWorkouts(id: dailyWorkoutEntity.id ?? UUID(), workouts: workoutEntries)
            } ?? []
            
            return WeeklyWorkouts(id: weeklyWorkoutEntity.id ?? UUID(), dailyWorkouts: dailyWorkoutEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntry: [WeeklyWorkoutsMO], with healthKitData: [WeeklyWorkouts], in context: NSManagedObjectContext) -> [WeeklyWorkoutsMO] {
        guard let coreDataMostRecentWeek = coreDataEntry.first,
              let coreDataMostRecentDay = coreDataMostRecentWeek.startDate,
              let coreDataLatestDay = coreDataEntry.last?.endDate else {
            return mapHealthKitToCoreData(healthKitData, context: context)
        }
        
        guard let healthKitMostRecentDay = healthKitData.first?.startDate,
              let healthKitLatestWeek = healthKitData.last,
              let healthKitLatestDay = healthKitLatestWeek.endDate,
              coreDataLatestDay <= healthKitMostRecentDay else {
            return coreDataEntry
        }
        
        let calendar = Calendar.current
        var mergedEntries = coreDataEntry
        
        if calendar.isDate(coreDataMostRecentDay, equalTo: healthKitLatestDay, toGranularity: .weekOfYear) {
            coreDataMostRecentWeek.endDate = healthKitLatestDay
            
            let newDailyWorkoutsEntries = mapHealthKitToCoreData([healthKitLatestWeek], context: context).first?.dailyWorkouts ?? []
            
            coreDataMostRecentWeek.addToDailyWorkouts(newDailyWorkoutsEntries)
            
            let historicalData = Array(healthKitData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newDailyWorkoutsEntries = mapHealthKitToCoreData(healthKitData, context: context)
            mergedEntries.insert(contentsOf: newDailyWorkoutsEntries, at: 0)
        }
        
        return mergedEntries
    }
}
                                                                 
                                                                 

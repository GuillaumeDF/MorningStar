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
        guard !healthKitData.isEmpty else {
            return coreDataEntry
        }
        
        guard !coreDataEntry.isEmpty else {
            return mapHealthKitToCoreData(healthKitData, context: context)
        }
        
        var mergedEntries = coreDataEntry
        let calendar = Calendar.current
        
        guard let lastHealthKitWeek = healthKitData.last,
              let firstCoreDataWeek = mergedEntries.first,
              let coreDataMostRecentWeekStart = firstCoreDataWeek.startDate,
              let lastHealthKitWeekStart = lastHealthKitWeek.startDate else {
            let newEntries = mapHealthKitToCoreData(healthKitData, context: context)
            mergedEntries.insert(contentsOf: newEntries, at: 0)
            return mergedEntries
        }
        
        if calendar.isDate(coreDataMostRecentWeekStart, equalTo: lastHealthKitWeekStart, toGranularity: .weekOfYear) {
            for dailyWorkouts in lastHealthKitWeek.dailyWorkouts {
                guard let dailyWorkoutsStartDate = dailyWorkouts.startDate else { continue }
                
                if let firstCoreDataWeekDays = firstCoreDataWeek.dailyWorkouts?.array as? [DailyWorkoutsMO],
                   let existingDay = firstCoreDataWeekDays.first(where: { existingDay in
                       if let existingStartDate = existingDay.startDate {
                           return calendar.isDate(existingStartDate, inSameDayAs: dailyWorkoutsStartDate)
                       }
                       return false
                   }) {
                    
                    let newWorkouts = dailyWorkouts.workouts.map { workout in
                        let workoutMO = WorkoutMO(context: context)
                        
                        workoutMO.id = workout.id
                        workoutMO.startDate = workout.startDate
                        workoutMO.endDate = workout.endDate
                        workoutMO.dailyWorkouts = existingDay
                        
                        let phaseEntries = workout.phaseEntries.map { phaseEntry in
                            let newEntry = WorkoutPhaseEntryMO(context: context)
                            
                            newEntry.id = phaseEntry.id
                            newEntry.averageHeartRate = phaseEntry.averageHeartRate
                            newEntry.caloriesBurned = phaseEntry.caloriesBurned
                            newEntry.value = Int16(phaseEntry.value.rawValue)
                            newEntry.startDate = phaseEntry.startDate
                            newEntry.endDate = phaseEntry.endDate
                            newEntry.workout = workoutMO
                            
                            return newEntry
                        }
                        
                        workoutMO.addToWorkoutPhaseEntries(NSOrderedSet(array: phaseEntries))
                        return workoutMO
                    }
                    
                    existingDay.addToWorkouts(NSOrderedSet(array: newWorkouts))
                    
                    if let latestWorkoutEndDate = newWorkouts.compactMap({ $0.endDate }).max(),
                       let existingEndDate = existingDay.endDate {
                        existingDay.endDate = max(existingEndDate, latestWorkoutEndDate)
                    }
                    
                } else {
                    let newDay = DailyWorkoutsMO(context: context)
                    newDay.id = dailyWorkouts.id
                    newDay.startDate = dailyWorkouts.startDate
                    newDay.endDate = dailyWorkouts.endDate
                    
                    let workoutEntities = dailyWorkouts.workouts.map { workout in
                        let workoutMO = WorkoutMO(context: context)
                        workoutMO.id = workout.id
                        workoutMO.startDate = workout.startDate
                        workoutMO.endDate = workout.endDate
                        workoutMO.dailyWorkouts = newDay
                        
                        let phaseEntries = workout.phaseEntries.map { phaseEntry in
                            let newEntry = WorkoutPhaseEntryMO(context: context)
                            
                            newEntry.id = phaseEntry.id
                            newEntry.averageHeartRate = phaseEntry.averageHeartRate
                            newEntry.caloriesBurned = phaseEntry.caloriesBurned
                            newEntry.value = Int16(phaseEntry.value.rawValue)
                            newEntry.startDate = phaseEntry.startDate
                            newEntry.endDate = phaseEntry.endDate
                            newEntry.workout = workoutMO
                            
                            return newEntry
                        }
                        
                        workoutMO.addToWorkoutPhaseEntries(NSOrderedSet(array: phaseEntries))
                        return workoutMO
                    }
                    
                    newDay.addToWorkouts(NSOrderedSet(array: workoutEntities))
                    firstCoreDataWeek.addToDailyWorkouts(newDay)
                }
            }
            
            if let latestDailyEndDate = firstCoreDataWeek.dailyWorkouts?.compactMap({ ($0 as? DailyWorkoutsMO)?.endDate }).max() {
                firstCoreDataWeek.endDate = max(firstCoreDataWeek.endDate ?? Date.distantPast, latestDailyEndDate)
            }
            
            let historicalData = Array(healthKitData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newEntries = mapHealthKitToCoreData(healthKitData, context: context)
            mergedEntries.insert(contentsOf: newEntries, at: 0)
        }
        
        return mergedEntries
    }
}
                                                                 
                                                                 

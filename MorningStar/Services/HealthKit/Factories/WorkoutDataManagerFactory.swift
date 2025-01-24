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
        return await withCheckedContinuation { continuation in
            HeartRateDataManagerFactory.createSampleQueryManager(
                for: healthStore,
                from: sample.startDate,
                to: sample.endDate
            )?.fetchData { heartRateResult in
                switch heartRateResult {
                case .success(let heartRateEntries):
                    CalorieBurnedDataManagerFactory.createSampleQueryManager(
                        for: healthStore,
                        from: sample.startDate,
                        to: sample.endDate
                    )?.fetchData { calorieResult in
                        switch calorieResult {
                        case .success(let calorieEntries):
                            let heartRates = heartRateEntries.first?.entries ?? []
                            let caloriesBurned = calorieEntries.first?.entries ?? []
                            
                            let workoutsWithIntensity = WorkoutIntensityAnalyzer().generateIntensityPhases(
                                sample: sample,
                                heartRates: heartRates,
                                caloriesBurned: caloriesBurned
                            )
                            
                            continuation.resume(returning: workoutsWithIntensity)
                            
                        case .failure(let error):
                            print("Failed to process calorie entries: \(error.localizedDescription)")
                            continuation.resume(returning: nil)
                        }
                    }
                case .failure(let error):
                    print("Failed to process heart rate entries: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[WeeklyWorkouts]>>? {
        nil
    }
    
    static func transformHealthKitToCoreData(_ healthKitData: [WeeklyWorkouts], context: NSManagedObjectContext) {
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
        }
    }
    
    static func transformCoreDataToHealthKit(_ coreDataEntry: [WeeklyWorkoutsMO]) -> [WeeklyWorkouts] {
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
}

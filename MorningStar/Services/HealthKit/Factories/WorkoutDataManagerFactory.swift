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
    typealias HealthDataType = WeeklyWorkouts
    typealias CoreDataType = WeeklyWorkoutsMO
    
    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        ]
    }
    
    static var id: HealthMetricType {
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
                        do {
                            return try await fetchDataForWorkout(healthStore: healthStore, sample: sample)
                        } catch {
                            Logger.logError(id, error: error)
                            return nil
                        }
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
    
    static func fetchDataForWorkout(healthStore: HKHealthStore, sample: HKSample) async throws -> Workout? {
        guard let heartRateEntries = try await HeartRateDataManagerFactory.createSampleQueryManager(
            for: healthStore,
            from: sample.startDate,
            to: sample.endDate
        )?.fetchData() else {
            throw(HealthKitError.healthKitManagerInitializationFailure)
        }
        
        guard let calorieEntries = try await CalorieBurnedDataManagerFactory.createSampleQueryManager(
            for: healthStore,
            from: sample.startDate,
            to: sample.endDate
        )?.fetchData() else {
            throw(HealthKitError.healthKitManagerInitializationFailure)
        }
        
        let heartRates = heartRateEntries.first?.entries ?? []
        let caloriesBurned = calorieEntries.first?.entries ?? []
        
        let workoutsWithIntensity = WorkoutIntensityAnalyzer().generateIntensityPhases(
            sample: sample,
            heartRates: heartRates,
            caloriesBurned: caloriesBurned
        )
        
        return workoutsWithIntensity
    }
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[WeeklyWorkouts]>>? {
        nil
    }
    
    static func mapHealthKitToCoreData(_ healthData: [WeeklyWorkouts], context: NSManagedObjectContext) -> [WeeklyWorkoutsMO] {
        healthData.map { weeklyWorkout in
            let newWeeklyWorkoutEntity = WeeklyWorkoutsMO(context: context)
            
            newWeeklyWorkoutEntity.id = weeklyWorkout.id
            newWeeklyWorkoutEntity.startDate = weeklyWorkout.startDate
            newWeeklyWorkoutEntity.endDate = weeklyWorkout.endDate
            
            let dailyWorkoutEntities = mapDailyWorkoutsToCoreData(weeklyWorkout.dailyWorkouts, parent: newWeeklyWorkoutEntity, context: context)
            
            newWeeklyWorkoutEntity.addToDailyWorkouts(NSOrderedSet(array: dailyWorkoutEntities))
            return newWeeklyWorkoutEntity
        }
    }
    
    private static func mapDailyWorkoutsToCoreData(_ dailyWorkouts: [DailyWorkouts],
                                           parent: WeeklyWorkoutsMO,
                                           context: NSManagedObjectContext) -> [DailyWorkoutsMO] {
        dailyWorkouts.map { dailyWorkout in
            let newDailyWorkoutEntity = DailyWorkoutsMO(context: context)
            
            newDailyWorkoutEntity.id = dailyWorkout.id
            newDailyWorkoutEntity.startDate = dailyWorkout.startDate
            newDailyWorkoutEntity.endDate = dailyWorkout.endDate
            newDailyWorkoutEntity.weeklyWorkout = parent
            
            let workoutEntities = mapWorkoutsToCoreData(dailyWorkout.workouts, parent: newDailyWorkoutEntity, context: context)
            newDailyWorkoutEntity.addToWorkouts(NSOrderedSet(array: workoutEntities))
            
            return newDailyWorkoutEntity
        }
    }
    
    private static func mapWorkoutsToCoreData(_ workouts: [Workout],
                                      parent: DailyWorkoutsMO,
                                      context: NSManagedObjectContext) -> [WorkoutMO] {
        workouts.map { workout in
            let newWorkoutEntity = WorkoutMO(context: context)
            
            newWorkoutEntity.id = workout.id
            newWorkoutEntity.startDate = workout.startDate
            newWorkoutEntity.endDate = workout.endDate
            newWorkoutEntity.dailyWorkouts = parent
            
            let phaseEntries = workout.phaseEntries.map { phaseEntry in
                let newPhaseEntry = WorkoutPhaseEntryMO(context: context)
                
                newPhaseEntry.id = phaseEntry.id
                newPhaseEntry.averageHeartRate = phaseEntry.averageHeartRate
                newPhaseEntry.caloriesBurned = phaseEntry.caloriesBurned
                newPhaseEntry.value = Int16(phaseEntry.value.rawValue)
                newPhaseEntry.startDate = phaseEntry.startDate
                newPhaseEntry.endDate = phaseEntry.endDate
                newPhaseEntry.workout = newWorkoutEntity
                
                return newPhaseEntry
            }
            
            newWorkoutEntity.addToWorkoutPhaseEntries(NSOrderedSet(array: phaseEntries))
            return newWorkoutEntity
        }
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntries: [WeeklyWorkoutsMO]) -> [WeeklyWorkouts] {
        coreDataEntries.map { weeklyWorkoutEntity in
            let dailyWorkoutEntries: [DailyWorkouts] = (weeklyWorkoutEntity.dailyWorkouts)?.compactMap { dailyWorkoutEntry in
                guard let dailyWorkoutEntity = dailyWorkoutEntry as? DailyWorkoutsMO else {
                    Logger.logWarning(id, message: "Can't cast dailyWorkoutEntry to DailyWorkoutsMO")
                    return nil
                }
                
                let workoutEntries: [Workout] = (dailyWorkoutEntity.workouts)?.compactMap { workoutEntry in
                    guard let workoutEntity = workoutEntry as? WorkoutMO else {
                        return nil
                    }
                    
                    let phaseEntries: [HealthData.WorkoutPhaseEntry] = (workoutEntity.workoutPhaseEntries)?.compactMap { phaseEntry in
                        guard let phaseEntity = phaseEntry as? WorkoutPhaseEntryMO,
                              let startDate = phaseEntity.startDate,
                              let endDate = phaseEntity.endDate else {
                            Logger.logWarning(id, message: "Can't cast phaseEntry to WorkoutPhaseEntryMO or startDate/endDate is nil")
                            return nil
                        }
                        
                        return HealthData.WorkoutPhaseEntry(
                            id: phaseEntity.id,
                            startDate: startDate,
                            endDate: endDate,
                            value: IntensityLevel(rawValue: Int(phaseEntity.value)) ?? .undetermined,
                            averageHeartRate: phaseEntity.averageHeartRate,
                            caloriesBurned: phaseEntity.caloriesBurned
                        )
                    } ?? []
                    
                    return Workout(id: workoutEntity.id, phaseEntries: phaseEntries)
                } ?? []
                
                return DailyWorkouts(id: dailyWorkoutEntity.id, workouts: workoutEntries)
            } ?? []
            
            return WeeklyWorkouts(id: weeklyWorkoutEntity.id, dailyWorkouts: dailyWorkoutEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [WeeklyWorkoutsMO], with healthData: [WeeklyWorkouts], in context: NSManagedObjectContext) -> [WeeklyWorkoutsMO] {
        guard let coreDataMostRecentWeek = coreDataEntries.first,
              let coreDataMostRecentDay = coreDataMostRecentWeek.startDate,
              let coreDataLatestDay = coreDataEntries.last?.endDate else {
            return mapHealthKitToCoreData(healthData, context: context)
        }
        
        guard let healthDataMostRecentDay = healthData.first?.startDate,
              let healthDataLatestWeek = healthData.last,
              let healthDataLatestDay = healthDataLatestWeek.endDate,
              coreDataLatestDay <= healthDataMostRecentDay else {
            return coreDataEntries
        }
        
        let calendar = Calendar.current
        var mergedEntries = coreDataEntries
        
        if calendar.isDate(coreDataMostRecentDay, equalTo: healthDataLatestDay, toGranularity: .weekOfYear) {
            coreDataMostRecentWeek.endDate = healthDataLatestDay
            
            if coreDataLatestDay.isSameDay(as: healthDataMostRecentDay),
               let coreDataMostRecentDaily = coreDataMostRecentWeek.dailyWorkouts?.lastObject as? DailyWorkoutsMO,
               let latestHealthKitDaily = healthDataLatestWeek.dailyWorkouts.last {
                coreDataMostRecentDaily.endDate = latestHealthKitDaily.endDate
               
                let newWorkoutEntities = mapWorkoutsToCoreData(latestHealthKitDaily.workouts, parent: coreDataMostRecentDaily, context: context)
                
                coreDataMostRecentDaily.addToWorkouts(NSOrderedSet(array: newWorkoutEntities))
            } else {
                let newDailyWorkoutsEntries = mapDailyWorkoutsToCoreData(healthDataLatestWeek.dailyWorkouts, parent: coreDataMostRecentWeek, context: context)

                coreDataMostRecentWeek.addToDailyWorkouts(NSOrderedSet(array: newDailyWorkoutsEntries))
            }
            
            let historicalData = Array(healthData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newDailyWorkoutsEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries.insert(contentsOf: newDailyWorkoutsEntries, at: 0)
        }
        
        return mergedEntries
    }
}
                                                                 
                                                                 

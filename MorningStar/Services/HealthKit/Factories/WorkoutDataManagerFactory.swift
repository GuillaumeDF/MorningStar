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
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [.strictStartDate, .strictEndDate]),
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
        var weeklyWorkoutEntities: [WeeklyWorkoutsMO] = []
        
        healthData.forEach { weeklyWorkout in
            let weeklyWorkoutEntity = WeeklyWorkoutsMO(context: context)
            weeklyWorkoutEntity.id = weeklyWorkout.id
            weeklyWorkoutEntity.startDate = weeklyWorkout.startDate
            weeklyWorkoutEntity.endDate = weeklyWorkout.endDate
            
            let dailyWorkoutEntities = mapHealthKitToCoreData(weeklyWorkout, in: context)
            dailyWorkoutEntities.forEach { dailyWorkoutEntity in
                if let newDailyWorkoutEntity = dailyWorkoutEntity as? DailyWorkoutsMO {
                    newDailyWorkoutEntity.weeklyWorkout = weeklyWorkoutEntity
                }
            }
            
            weeklyWorkoutEntity.addToDailyWorkouts(dailyWorkoutEntities)
            weeklyWorkoutEntities.append(weeklyWorkoutEntity)
        }
        
        return weeklyWorkoutEntities
    }
    
    static func mapHealthKitToCoreData(_ dailyWorkouts: DailyWorkouts, in context: NSManagedObjectContext) -> NSOrderedSet {
        let workoutEntities = dailyWorkouts.workouts.map { workout in
            let workoutEntity = WorkoutMO(context: context)
            
            workoutEntity.id = workout.id
            workoutEntity.startDate = workout.startDate
            workoutEntity.endDate = workout.endDate
            
            let phaseEntries = workout.phaseEntries.map { phaseEntry in
                let newPhaseEntry = WorkoutPhaseEntryMO(context: context)
                
                newPhaseEntry.id = phaseEntry.id
                newPhaseEntry.averageHeartRate = phaseEntry.averageHeartRate
                newPhaseEntry.caloriesBurned = phaseEntry.caloriesBurned
                newPhaseEntry.value = Int16(phaseEntry.value.rawValue)
                newPhaseEntry.startDate = phaseEntry.startDate
                newPhaseEntry.endDate = phaseEntry.endDate
                newPhaseEntry.workout = workoutEntity
                
                return newPhaseEntry
            }
            
            workoutEntity.addToWorkoutPhaseEntries(NSOrderedSet(array: phaseEntries))
            return workoutEntity
        }
        
        return NSOrderedSet(array: workoutEntities)
    }

    static func mapHealthKitToCoreData(_ weeklyWorkout: WeeklyWorkouts, in context: NSManagedObjectContext) -> NSOrderedSet {
        let dailyWorkoutEntities = weeklyWorkout.dailyWorkouts.map { dailyWorkouts in
            let dailyWorkoutEntity = DailyWorkoutsMO(context: context)
            
            dailyWorkoutEntity.id = dailyWorkouts.id
            dailyWorkoutEntity.startDate = dailyWorkouts.startDate
            dailyWorkoutEntity.endDate = dailyWorkouts.endDate
            
            let workoutEntities = mapHealthKitToCoreData(dailyWorkouts, in: context)
            workoutEntities.forEach { workoutEntry in
                if let newWorkoutEntry = workoutEntry as? WorkoutMO {
                    newWorkoutEntry.dailyWorkouts = dailyWorkoutEntity
                }
            }
            
            dailyWorkoutEntity.addToWorkouts(workoutEntities)
            return dailyWorkoutEntity
        }
        
        return NSOrderedSet(array: dailyWorkoutEntities)
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntries: [WeeklyWorkoutsMO]) -> [WeeklyWorkouts] {
        return coreDataEntries.map { weeklyWorkoutEntity in
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
               
                let newWorkoutEntities = mapHealthKitToCoreData(latestHealthKitDaily, in: context)
                
                newWorkoutEntities.forEach { workoutEntry in
                    if let newWorkoutEntry = workoutEntry as? WorkoutMO {
                        newWorkoutEntry.dailyWorkouts = coreDataMostRecentDaily
                    }
                }
                
                coreDataMostRecentDaily.addToWorkouts(newWorkoutEntities)
            } else {
                let newDailyWorkoutsEntries = mapHealthKitToCoreData(healthDataLatestWeek, in: context)
                
                newDailyWorkoutsEntries.forEach { dailyWorkoutEntity in
                    if let newDailyWorkoutEntity = dailyWorkoutEntity as? DailyWorkoutsMO {
                        newDailyWorkoutEntity.weeklyWorkout = coreDataMostRecentWeek
                    }
                }
                
                coreDataMostRecentWeek.addToDailyWorkouts(newDailyWorkoutsEntries)
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
                                                                 
                                                                 

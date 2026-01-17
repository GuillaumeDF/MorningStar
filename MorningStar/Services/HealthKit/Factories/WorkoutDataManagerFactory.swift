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
    typealias CoreDataType = WorkoutMO

    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        ]
    }

    static var id: HealthMetricType { .workouts }

    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<SampleQueryDescriptor<[WeeklyWorkouts]>>? {
        let queryDescriptor = SampleQueryDescriptor<[WeeklyWorkouts]>(
            sampleType: HKObjectType.workoutType(),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
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

        guard let calorieEntries = try await CalorieBurnedDataManagerFactory.createSampleQueryManagerWithoutSort(
            for: healthStore,
            from: sample.startDate,
            to: sample.endDate
        )?.fetchData() else {
            throw(HealthKitError.healthKitManagerInitializationFailure)
        }

        let heartRates = heartRateEntries.first?.entries ?? []
        let caloriesBurned = calorieEntries.first?.entries ?? []

        let workoutsWithIntensity = WorkoutIntensityAnalyzer().generateWorkout(
            sample: sample,
            heartRates: heartRates,
            caloriesBurned: caloriesBurned
        )

        return workoutsWithIntensity
    }

    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[WeeklyWorkouts]>>? {
        nil
    }

    static func mapHealthKitToCoreData(_ healthData: [WeeklyWorkouts], context: NSManagedObjectContext) -> [WorkoutMO] {
        healthData.flatMap { weeklyWorkout in
            weeklyWorkout.dailyWorkouts.flatMap { dailyWorkout in
                dailyWorkout.workouts.map { workout in
                    let workoutMO = WorkoutMO(context: context)
                    workoutMO.id = workout.id
                    workoutMO.startDate = workout.startDate
                    workoutMO.endDate = workout.endDate
                    workoutMO.type = Int16(workout.type)

                    let phaseMOs = workout.phaseEntries.map { phase in
                        let phaseMO = WorkoutPhaseEntryMO(context: context)
                        phaseMO.id = phase.id
                        phaseMO.startDate = phase.startDate
                        phaseMO.endDate = phase.endDate
                        phaseMO.value = Int16(phase.value.rawValue)
                        phaseMO.averageHeartRate = phase.averageHeartRate
                        phaseMO.caloriesBurned = phase.caloriesBurned
                        phaseMO.unit = phase.unit
                        phaseMO.workout = workoutMO
                        return phaseMO
                    }

                    workoutMO.addToWorkoutPhaseEntries(NSOrderedSet(array: phaseMOs))
                    return workoutMO
                }
            }
        }
    }

    static func mapCoreDataToHealthKit(_ coreDataEntries: [WorkoutMO]) -> [WeeklyWorkouts] {
        let calendar = Calendar.current

        let workouts: [Workout] = coreDataEntries.map { workoutMO in
            let phases: [HealthData.WorkoutPhaseEntry] = (workoutMO.workoutPhaseEntries)?.compactMap { phase in
                guard let phaseMO = phase as? WorkoutPhaseEntryMO,
                      let startDate = phaseMO.startDate,
                      let endDate = phaseMO.endDate else {
                    return nil
                }

                return HealthData.WorkoutPhaseEntry(
                    id: phaseMO.id,
                    startDate: startDate,
                    endDate: endDate,
                    value: IntensityLevel(rawValue: UInt8(phaseMO.value)) ?? .undetermined,
                    averageHeartRate: phaseMO.averageHeartRate,
                    caloriesBurned: phaseMO.caloriesBurned
                )
            } ?? []

            return Workout(
                id: workoutMO.id,
                type: UInt16(workoutMO.type),
                phaseEntries: phases
            )
        }

        let groupedByDay = Dictionary(grouping: workouts) { workout in
            calendar.startOfDay(for: workout.startDate ?? Date())
        }

        let dailyWorkouts: [DailyWorkouts] = groupedByDay
            .sorted { $0.key < $1.key }
            .map { (_, workouts) in
                DailyWorkouts(workouts: workouts.sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) })
            }

        let groupedByWeek = Dictionary(grouping: dailyWorkouts) { daily in
            calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: daily.startDate ?? Date())
        }

        return groupedByWeek
            .sorted { lhs, rhs in
                let lhsDate = calendar.date(from: lhs.key) ?? .distantPast
                let rhsDate = calendar.date(from: rhs.key) ?? .distantPast
                return lhsDate > rhsDate
            }
            .map { (_, dailies) in
                WeeklyWorkouts(dailyWorkouts: dailies.sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) })
            }
    }

    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [WorkoutMO], with healthData: [WeeklyWorkouts], in context: NSManagedObjectContext) -> [WorkoutMO] {
        let existingIds = Set(coreDataEntries.compactMap { $0.id })

        let newWorkouts = healthData.flatMap { weekly in
            weekly.dailyWorkouts.flatMap { daily in
                daily.workouts.filter { !existingIds.contains($0.id) }
            }
        }

        let addedEntries = newWorkouts.map { workout -> WorkoutMO in
            let workoutMO = WorkoutMO(context: context)
            workoutMO.id = workout.id
            workoutMO.startDate = workout.startDate
            workoutMO.endDate = workout.endDate
            workoutMO.type = Int16(workout.type)

            let phaseMOs = workout.phaseEntries.map { phase in
                let phaseMO = WorkoutPhaseEntryMO(context: context)
                phaseMO.id = phase.id
                phaseMO.startDate = phase.startDate
                phaseMO.endDate = phase.endDate
                phaseMO.value = Int16(phase.value.rawValue)
                phaseMO.averageHeartRate = phase.averageHeartRate
                phaseMO.caloriesBurned = phase.caloriesBurned
                phaseMO.unit = phase.unit
                phaseMO.workout = workoutMO
                return phaseMO
            }

            workoutMO.addToWorkoutPhaseEntries(NSOrderedSet(array: phaseMOs))
            return workoutMO
        }

        return addedEntries + coreDataEntries
    }
}

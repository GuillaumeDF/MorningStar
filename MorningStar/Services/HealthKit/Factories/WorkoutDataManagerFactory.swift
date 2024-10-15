//
//  WorkoutDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit

class WorkoutDataManagerFactory {
    static func createSampleManager(
        healthStore: HKHealthStore,
        from startDate: Date,
        to endDate: Date = Date()
    ) -> HealthDataManager<SampleQueryDescriptor<HealthData.WorkoutHistory>> {
        
        let queryDescriptor = SampleQueryDescriptor<HealthData.WorkoutHistory>(
            sampleType: HKObjectType.workoutType(),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples async in
            var workoutsWithIntensity: [HealthData.WorkoutPhaseEntries] = []
            
            await withTaskGroup(of: HealthData.WorkoutPhaseEntries?.self) { group in
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
            
            return HealthDataProcessor.groupWorkoutsByDayAndWeek(workoutsWithIntensity)
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func fetchDataForWorkout(healthStore: HKHealthStore, sample: HKSample) async -> HealthData.WorkoutPhaseEntries? {
        return await withCheckedContinuation { continuation in
            HeartRateDataManagerFactory.createSampleManager(
                healthStore: healthStore,
                from: sample.startDate,
                to: sample.endDate
            ).fetchData { heartRateResult in
                switch heartRateResult {
                case .success(let heartRateEntries):
                    CalorieBurnedDataManagerFactory.createSampleManager(
                        healthStore: healthStore,
                        from: sample.startDate,
                        to: sample.endDate
                    ).fetchData { calorieResult in
                        switch calorieResult {
                        case .success(let calorieEntries):
                            let heartRatesT = heartRateEntries.entries
                            let caloriesBurnedTmp = calorieEntries.first?.entries ?? []
                            
                            let workoutsWithIntensity = WorkoutIntensityAnalyzer().generateIntensityPhases(
                                workout: sample,
                                heartRates: heartRatesT,
                                caloriesBurned: caloriesBurnedTmp
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
}

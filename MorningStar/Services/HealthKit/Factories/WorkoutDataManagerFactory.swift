//
//  WorkoutDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit

class WorkoutDataManagerFactory {
    static func createSampleManager(healthStore: HKHealthStore, from startDate: Date, to endDate: Date = Date()) -> HealthDataManager<SampleQueryDescriptor<[PeriodEntry<HealthData.WorkoutEntry>]>> {
        let queryDescriptor = SampleQueryDescriptor<[PeriodEntry<HealthData.WorkoutEntry>]>(
            sampleType: HKObjectType.workoutType(),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            for sample in samples {
                HeartRateDataManagerFactory.createSampleManager(healthStore: healthStore, from: sample.startDate, to: sample.endDate).fetchData { heartRates in
                    CalorieBurnedDataManagerFactory.createSampleManager(healthStore: healthStore, from: sample.startDate, to: sample.endDate).fetchData { calorieBurned in
                        var heartRatesT: [HealthData.HeartRateEntry] = []
                        var caloriesBurnedTmp: [HealthData.ActivityEntry] = []
                        
                        print("Workout: \(sample.startDate) - \(sample.endDate)")
                        switch heartRates {
                        case .success(let entries):
                            heartRatesT = entries.entries
                            //print("Average HeartRate: \(entries)")
                        case .failure(let error):
                            print("no heart rate data: \(error)")
                        }
                        switch calorieBurned {
                        case .success(let entries):
                            caloriesBurnedTmp = entries.first!.entries
                            //print("Average Calorie Burned: \(entries)")
                        case .failure(let error):
                            print("no calorie burned data: \(error)")
                        }
                        let t = WorkoutIntensityAnalyzer().generateIntensityPhases(workout: sample, heartRates: heartRatesT, caloriesBurned: caloriesBurnedTmp)
                        t.forEach { workout in
                            print(workout.value)
                        }
                        print("--------------------------------")
                    }
                }
            }
            return []
        }
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
}

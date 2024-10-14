//
//  SleepDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit

class SleepDataManagerFactory {
    static func createSampleManager(healthStore: HKHealthStore, from startDate: Date, to endDate: Date = Date()) -> HealthDataManager<SampleQueryDescriptor<[PeriodEntry<HealthData.SleepEntry>]>> {
        let queryDescriptor = SampleQueryDescriptor<[PeriodEntry<HealthData.SleepEntry>]>(
            sampleType: HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            return HealthDataProcessor.groupSleepByNight(from: samples)
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
}

//
//  WeightDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit

struct WeightDataManagerFactory {
    static func createSampleManager(healthStore: HKHealthStore, from startDate: Date, to endDate: Date = Date()) -> HealthDataManager<SampleQueryDescriptor<[PeriodEntry<HealthData.WeightEntry>]>> {
        let queryDescriptor = SampleQueryDescriptor<[PeriodEntry<HealthData.WeightEntry>]>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            HealthDataProcessor.groupWeightsByWeek(from: samples, unit: .gramUnit(with: .kilo))
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
}

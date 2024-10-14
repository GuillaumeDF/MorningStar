//
//  HeartRateDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit

class HeartRateDataManagerFactory {
    static func createSampleManager(healthStore: HKHealthStore, from startDate: Date, to endDate: Date = Date()) -> HealthDataManager<SampleQueryDescriptor<PeriodEntry<HealthData.HeartRateEntry>>> {
        let queryDescriptor = SampleQueryDescriptor<PeriodEntry<HealthData.HeartRateEntry>>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            
            let heartRateEntries: [HealthData.HeartRateEntry] = samples.compactMap { sample in
                guard let quantitySample = sample as? HKQuantitySample else { return nil }
                let heartRateValue = quantitySample.quantity.doubleValue(for: heartRateUnit)
                
                return HealthData.HeartRateEntry(
                    startDate: quantitySample.startDate,
                    endDate: quantitySample.endDate,
                    value: heartRateValue
                )
            }
            
            let heartRates = PeriodEntry<HealthData.HeartRateEntry>(entries: heartRateEntries)
            
            return heartRates
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
}

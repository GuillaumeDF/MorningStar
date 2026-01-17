//
//  HeartRateDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

struct HeartRateDataManagerFactory {
    typealias HealthDataType = HeartRatePeriod
    typealias CoreDataType = HeartRateEntryMO

    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[HeartRatePeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[HeartRatePeriod]>(
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

            return [PeriodEntry<HealthData.HeartRateEntry>(entries: heartRateEntries)]
        }

        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func mapHealthKitToCoreData(_ healthData: [HeartRatePeriod], context: NSManagedObjectContext) -> [HeartRateEntryMO] {
        healthData.flatMap { period in
            period.entries.map { entry in
                let mo = HeartRateEntryMO(context: context)
                mo.id = entry.id
                mo.startDate = entry.startDate
                mo.endDate = entry.endDate
                mo.value = entry.value
                mo.unit = entry.unit
                return mo
            }
        }
    }

    static func mapCoreDataToHealthKit(_ coreDataEntries: [HeartRateEntryMO]) -> [HeartRatePeriod] {
        let healthEntries = coreDataEntries
            .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }
            .map { entry in
                HealthData.HeartRateEntry(
                    id: entry.id,
                    startDate: entry.startDate ?? Date(),
                    endDate: entry.endDate ?? Date(),
                    value: entry.value
                )
            }
        return [PeriodEntry(entries: healthEntries)]
    }
}

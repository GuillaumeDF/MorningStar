//
//  SleepDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

struct SleepDataManagerFactory: HealthDataFactoryProtocol {
    typealias HealthDataType = SleepPeriod
    typealias CoreDataType = SleepEntryMO

    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)]
    }

    static var id: HealthMetricType { .sleep }

    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<SampleQueryDescriptor<[SleepPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[SleepPeriod]>(
            sampleType: HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            HealthDataProcessor.groupSleepByNight(from: samples)
        }

        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[SleepPeriod]>>? {
        nil
    }

    static func mapHealthKitToCoreData(_ healthData: [SleepPeriod], context: NSManagedObjectContext) -> [SleepEntryMO] {
        healthData.flatMap { period in
            period.entries.map { entry in
                let mo = SleepEntryMO(context: context)
                mo.id = entry.id
                mo.startDate = entry.startDate
                mo.endDate = entry.endDate
                mo.unit = entry.unit
                return mo
            }
        }
    }

    static func mapCoreDataToHealthKit(_ coreDataEntries: [SleepEntryMO]) -> [SleepPeriod] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: coreDataEntries) { entry in
            calendar.startOfDay(for: entry.endDate ?? Date())
        }

        return grouped
            .sorted { $0.key > $1.key }
            .map { (_, entries) in
                let healthEntries = entries
                    .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }
                    .map { entry in
                        HealthData.SleepEntry(
                            id: entry.id,
                            startDate: entry.startDate ?? Date(),
                            endDate: entry.endDate ?? Date(),
                            unit: entry.unit ?? ""
                        )
                    }
                return PeriodEntry(entries: healthEntries)
            }
    }

    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [SleepEntryMO], with healthData: [SleepPeriod], in context: NSManagedObjectContext) -> [SleepEntryMO] {
        let existingIds = Set(coreDataEntries.compactMap { $0.id })
        let newEntries = healthData.flatMap { $0.entries }
        let entriesToAdd = newEntries.filter { !existingIds.contains($0.id) }

        let addedEntries = entriesToAdd.map { entry -> SleepEntryMO in
            let mo = SleepEntryMO(context: context)
            mo.id = entry.id
            mo.startDate = entry.startDate
            mo.endDate = entry.endDate
            mo.unit = entry.unit
            return mo
        }

        return addedEntries + coreDataEntries
    }
}

//
//  WeightDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

struct WeightDataManagerFactory: HealthDataFactoryProtocol {
    typealias HealthDataType = WeightPeriod
    typealias CoreDataType = WeightEntryMO

    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [HKQuantityType.quantityType(forIdentifier: .bodyMass)]
    }

    static var id: HealthMetricType { .weight }

    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<SampleQueryDescriptor<[WeightPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[WeightPeriod]>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            HealthDataProcessor.groupWeightsByWeek(from: samples, unit: .gramUnit(with: .kilo))
        }

        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[WeightPeriod]>>? {
        nil
    }

    static func mapHealthKitToCoreData(_ healthData: [WeightPeriod], context: NSManagedObjectContext) -> [WeightEntryMO] {
        healthData.flatMap { period in
            period.entries.map { entry in
                let mo = WeightEntryMO(context: context)
                mo.id = entry.id
                mo.startDate = entry.startDate
                mo.endDate = entry.endDate
                mo.value = entry.value
                mo.unit = entry.unit
                return mo
            }
        }
    }

    static func mapCoreDataToHealthKit(_ coreDataEntries: [WeightEntryMO]) -> [WeightPeriod] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: coreDataEntries) { entry in
            calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: entry.startDate ?? Date())
        }

        return grouped
            .sorted { lhs, rhs in
                let lhsDate = calendar.date(from: lhs.key) ?? .distantPast
                let rhsDate = calendar.date(from: rhs.key) ?? .distantPast
                return lhsDate > rhsDate
            }
            .map { (_, entries) in
                let healthEntries = entries
                    .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }
                    .map { entry in
                        HealthData.WeightEntry(
                            id: entry.id,
                            startDate: entry.startDate ?? Date(),
                            endDate: entry.endDate ?? Date(),
                            value: entry.value,
                            unit: entry.unit ?? ""
                        )
                    }
                return PeriodEntry(entries: healthEntries)
            }
    }

    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [WeightEntryMO], with healthData: [WeightPeriod], in context: NSManagedObjectContext) -> [WeightEntryMO] {
        let existingIds = Set(coreDataEntries.compactMap { $0.id })
        let newEntries = healthData.flatMap { $0.entries }
        let entriesToAdd = newEntries.filter { !existingIds.contains($0.id) }

        let addedEntries = entriesToAdd.map { entry -> WeightEntryMO in
            let mo = WeightEntryMO(context: context)
            mo.id = entry.id
            mo.startDate = entry.startDate
            mo.endDate = entry.endDate
            mo.value = entry.value
            mo.unit = entry.unit
            return mo
        }

        return addedEntries + coreDataEntries
    }
}

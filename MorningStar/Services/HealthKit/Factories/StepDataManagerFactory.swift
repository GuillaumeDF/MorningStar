//
//  StepDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

struct StepDataManagerFactory: HealthDataFactoryProtocol {
    typealias HealthDataType = StepPeriod
    typealias CoreDataType = StepEntryMO

    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [HKQuantityType.quantityType(forIdentifier: .stepCount)]
    }

    static var id: HealthMetricType { .steps }

    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<SampleQueryDescriptor<[StepPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[StepPeriod]>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            HealthDataProcessor.groupActivitiesByDay(from: samples, unit: HKUnit.count())
        }

        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[StepPeriod]>>? {
        var utcCalendar = Calendar.current
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!

        let queryDescriptor = StatisticsCollectionQueryDescriptor<[StepPeriod]>(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            anchorDate: utcCalendar.startOfDay(for: startDate),
            intervalComponents: DateComponents(hour: 1),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
            options: .cumulativeSum
        ) { statisticsCollection in
            HealthDataProcessor.groupActivitiesByDay(for: statisticsCollection, from: startDate, to: endDate ?? Date(), unit: HKUnit.count())
        }

        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func mapHealthKitToCoreData(_ healthData: [StepPeriod], context: NSManagedObjectContext) -> [StepEntryMO] {
        healthData.flatMap { period in
            period.entries.map { entry in
                let mo = StepEntryMO(context: context)
                mo.id = entry.id
                mo.startDate = entry.startDate
                mo.endDate = entry.endDate
                mo.value = entry.value
                mo.unit = entry.unit
                return mo
            }
        }
    }

    static func mapCoreDataToHealthKit(_ coreDataEntries: [StepEntryMO]) -> [StepPeriod] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: coreDataEntries) { entry in
            calendar.startOfDay(for: entry.startDate ?? Date())
        }

        return grouped
            .sorted { $0.key > $1.key }
            .map { (_, entries) in
                let healthEntries = entries
                    .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }
                    .map { entry in
                        HealthData.ActivityEntry(
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

    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [StepEntryMO], with healthData: [StepPeriod], in context: NSManagedObjectContext) -> [StepEntryMO] {
        let existingIds = Set(coreDataEntries.compactMap { $0.id })
        let newEntries = healthData.flatMap { $0.entries }
        let entriesToAdd = newEntries.filter { !existingIds.contains($0.id) }

        let addedEntries = entriesToAdd.map { entry -> StepEntryMO in
            let mo = StepEntryMO(context: context)
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

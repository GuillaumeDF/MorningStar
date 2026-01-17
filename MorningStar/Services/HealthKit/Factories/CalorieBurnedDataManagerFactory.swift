//
//  CalorieBurnedDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

struct CalorieBurnedDataManagerFactory: HealthDataFactoryProtocol {
    typealias HealthDataType = CaloriesPeriod
    typealias CoreDataType = CalorieEntryMO

    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)]
    }

    static var id: HealthMetricType { .calories }

    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<SampleQueryDescriptor<[CaloriesPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[CaloriesPeriod]>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            HealthDataProcessor.groupActivitiesByDay(from: samples, unit: HKUnit.kilocalorie())
        }

        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[CaloriesPeriod]>>? {
        var utcCalendar = Calendar.current
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!

        let queryDescriptor = StatisticsCollectionQueryDescriptor<[PeriodEntry<HealthData.ActivityEntry>]>(
            quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            anchorDate: utcCalendar.startOfDay(for: startDate),
            intervalComponents: DateComponents(hour: 1),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            options: .cumulativeSum
        ) { statisticsCollection in
            HealthDataProcessor.groupActivitiesByDay(for: statisticsCollection, from: startDate, to: endDate ?? Date(), unit: HKUnit.kilocalorie())
        }

        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func createSampleQueryManagerWithoutSort(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<SampleQueryDescriptor<[CaloriesPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[CaloriesPeriod]>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            let activities = samples.compactMap { sample -> HealthData.ActivityEntry? in
                guard let quantitySample = sample as? HKQuantitySample else { return nil }
                let caloriesBurned = quantitySample.quantity.doubleValue(for: HKUnit.kilocalorie())

                return HealthData.ActivityEntry(
                    startDate: quantitySample.startDate,
                    endDate: quantitySample.endDate,
                    value: caloriesBurned,
                    unit: HKUnit.kilocalorie().unitString
                )
            }

            return [PeriodEntry(entries: activities)]
        }

        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }

    static func mapHealthKitToCoreData(_ healthData: [CaloriesPeriod], context: NSManagedObjectContext) -> [CalorieEntryMO] {
        healthData.flatMap { period in
            period.entries.map { entry in
                let mo = CalorieEntryMO(context: context)
                mo.id = entry.id
                mo.startDate = entry.startDate
                mo.endDate = entry.endDate
                mo.value = entry.value
                mo.unit = entry.unit
                return mo
            }
        }
    }

    static func mapCoreDataToHealthKit(_ coreDataEntries: [CalorieEntryMO]) -> [CaloriesPeriod] {
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

    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [CalorieEntryMO], with healthData: [CaloriesPeriod], in context: NSManagedObjectContext) -> [CalorieEntryMO] {
        let existingIds = Set(coreDataEntries.compactMap { $0.id })
        let newEntries = healthData.flatMap { $0.entries }
        let entriesToAdd = newEntries.filter { !existingIds.contains($0.id) }

        let addedEntries = entriesToAdd.map { entry -> CalorieEntryMO in
            let mo = CalorieEntryMO(context: context)
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

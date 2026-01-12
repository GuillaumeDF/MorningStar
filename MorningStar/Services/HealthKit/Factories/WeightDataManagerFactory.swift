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
    typealias HealthDataType =  WeightPeriod
    typealias CoreDataType = PeriodEntryMO
    
    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [
            HKQuantityType.quantityType(forIdentifier: .bodyMass)
        ]
    }
    
    static var id: HealthMetricType {
        .weight
    }
    
    static var predicateCoreData: NSPredicate? {
        NSPredicate(format: "weightEntries.@count > 0")
    }
    
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
    
    static func mapHealthKitToCoreData(_ healthData: [WeightPeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        healthData.compactMap { weightPeriod in
            guard let startDate = weightPeriod.entries.first?.startDate,
                  let endDate = weightPeriod.entries.last?.endDate else {
                Logger.logWarning(id, message: "Can't retry startDate or endDate WeightPeriod \(weightPeriod.id)")
                return nil
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = weightPeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let weightEntries = mapWeightEntriesToCoreData(weightPeriod.entries, parent: periodEntity, context: context)
            periodEntity.addToWeightEntries(NSOrderedSet(array: weightEntries))
            
            return periodEntity
        }
    }
    
    private static func mapWeightEntriesToCoreData(_ weightEntries: [HealthData.WeightEntry],
                                                   parent: PeriodEntryMO,
                                                   context: NSManagedObjectContext) -> [WeightEntryMO] {
        weightEntries.map { weightEntry in
            let newWeightEntity = WeightEntryMO(context: context)
            
            newWeightEntity.id = weightEntry.id
            newWeightEntity.startDate = weightEntry.startDate
            newWeightEntity.endDate = weightEntry.endDate
            newWeightEntity.value = weightEntry.value
            newWeightEntity.unit = weightEntry.unit
            newWeightEntity.periodEntry = parent
            
            return newWeightEntity
        }
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntries: [PeriodEntryMO]) -> [WeightPeriod] {
        return coreDataEntries.map { periodEntity in
            let weightEntries: [HealthData.WeightEntry] = (periodEntity.weightEntries)?.compactMap { entry in
                guard let weightEntity = entry as? WeightEntryMO,
                      let startDate = weightEntity.startDate,
                      let endDate = weightEntity.endDate else {
                    return nil
                }
                
                return HealthData.WeightEntry(
                    id: weightEntity.id,
                    startDate: startDate,
                    endDate: endDate,
                    value: weightEntity.value,
                    unit: weightEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id, entries: weightEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [PeriodEntryMO], with healthData: [WeightPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
        Logger.logInfo(id, message: "Starting merge process with coreData entries an healthData entries")
        guard let mostRecentCoreDataEntry = coreDataEntries.first,
              let mostRecentCoreDataEndDate = mostRecentCoreDataEntry.endDate else {
            Logger.logWarning(id, message: "CoreData entries are empty or invalid, mapping HealthKit data to CoreData")
            return mapHealthKitToCoreData(healthData, context: context)
        }

        guard let oldestHealthDataEntry = healthData.last,
              let oldestHealthDataEndDate = oldestHealthDataEntry.endDate,
              let oldestHealthDataStartDate = oldestHealthDataEntry.startDate else {
            Logger.logWarning(id, message: "HealthKit entries are empty or invalid, mapping HealthKit data to CoreData")
            return coreDataEntries
        }

        var mergedEntries = coreDataEntries

        if mostRecentCoreDataEndDate.isSameWeek(as: oldestHealthDataStartDate) {
            Logger.logInfo(id, message: "Updating most recent CoreData entry with HealthKit data")
            mostRecentCoreDataEntry.endDate =  oldestHealthDataEndDate

            let newWeightEntries = mapWeightEntriesToCoreData(oldestHealthDataEntry.entries, parent: mostRecentCoreDataEntry, context: context)
            mostRecentCoreDataEntry.addToWeightEntries(NSOrderedSet(array: newWeightEntries))

            let historicalData = healthData.dropLast()
            if !historicalData.isEmpty {
                Logger.logInfo(id, message: "Adding historical HealthKit data to CoreData")
                let historicalEntries = mapHealthKitToCoreData(Array(historicalData), context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            Logger.logInfo(id, message: "Mapping all HealthKit data to CoreData")
            let newWeightEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries.insert(contentsOf: newWeightEntries, at: 0)
        }

        Logger.logInfo(id, message: "Merge process completed")
        return mergedEntries
    }
}

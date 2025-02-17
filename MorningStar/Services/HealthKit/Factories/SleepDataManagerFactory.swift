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
    typealias CoreDataType = PeriodEntryMO
    
    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [
            HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)
        ]
    }
    
    static var id: HealthMetricType {
        .sleep
    }
    
    static var predicateCoreData: NSPredicate? {
        NSPredicate(format: "sleepEntries.@count > 0")
    }
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[SleepPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[SleepPeriod]>(
            sampleType: HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            HealthDataProcessor.groupSleepByNight(from: samples)
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[SleepPeriod]>>? {
        nil
    }
    
    static func mapHealthKitToCoreData(_ healthData: [SleepPeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        healthData.compactMap { sleepPeriod in
            guard let startDate = sleepPeriod.entries.first?.startDate,
                  let endDate = sleepPeriod.entries.last?.endDate else {
                Logger.logWarning(id, message: "Can't retry startDate or endDate in SleepPeriod \(sleepPeriod.id)")
                return nil
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = sleepPeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let sleepEntities = mapSleepEntriesToCoreData(sleepPeriod.entries, parent: periodEntity, context: context)
            periodEntity.addToSleepEntries(NSOrderedSet(array: sleepEntities))
            
            return periodEntity
        }
    }
    
    private static func mapSleepEntriesToCoreData(_ sleepEntries: [HealthData.SleepEntry],
                                          parent: PeriodEntryMO,
                                          context: NSManagedObjectContext) -> [SleepEntryMO] {
        sleepEntries.map { sleepEntry in
            let newSleepEntity = SleepEntryMO(context: context)
            
            newSleepEntity.id = sleepEntry.id
            newSleepEntity.startDate = sleepEntry.startDate
            newSleepEntity.endDate = sleepEntry.endDate
            newSleepEntity.unit = sleepEntry.unit
            newSleepEntity.periodEntry = parent

            return newSleepEntity
        }
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntries: [PeriodEntryMO]) -> [SleepPeriod] {
        coreDataEntries.map { periodEntity in
            let sleepEntries: [HealthData.SleepEntry] = (periodEntity.sleepEntries)?.compactMap { entry in
                guard let sleepEntity = entry as? SleepEntryMO,
                      let startDate = sleepEntity.startDate,
                      let endDate = sleepEntity.endDate else {
                    return nil
                }
                
                return HealthData.SleepEntry(
                    id: sleepEntity.id,
                    startDate: startDate,
                    endDate: endDate,
                    unit: sleepEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id, entries: sleepEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [PeriodEntryMO], with healthData: [SleepPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
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
        
        if mostRecentCoreDataEndDate.hoursBetween(and: oldestHealthDataStartDate) <= AppConstants.Duration.isNightSleep {
            Logger.logInfo(id, message: "Updating most recent CoreData entry with HealthKit data")
            mostRecentCoreDataEntry.endDate =  oldestHealthDataEndDate
            
            let newSleepEntries = mapSleepEntriesToCoreData(oldestHealthDataEntry.entries, parent: mostRecentCoreDataEntry, context: context)
            mostRecentCoreDataEntry.addToSleepEntries(NSOrderedSet(array: newSleepEntries))
            
            let historicalData = Array(healthData.dropLast())
            if !historicalData.isEmpty {
                Logger.logInfo(id, message: "Adding historical HealthKit data to CoreData")
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            Logger.logInfo(id, message: "Mapping all HealthKit data to CoreData")
            let newSleepEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries.insert(contentsOf: newSleepEntries, at: 0)
        }
        
        Logger.logInfo(id, message: "Merge process completed")
        return mergedEntries
    }
}

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
        guard let coreDataMostRecentDay = coreDataEntries.first,
              let coreDataLatestDate = coreDataEntries.last?.endDate else {
            return mapHealthKitToCoreData(healthData, context: context)
        }
        
        guard let healthDataMostRecentDate = healthData.first?.startDate,
              let healthDataLatestDay = healthData.last,
              let healthDataLatestDate = healthDataLatestDay.endDate,
              coreDataLatestDate <= healthDataMostRecentDate else {
            return coreDataEntries
        }
        
        var mergedEntries = coreDataEntries
        
        if healthDataMostRecentDate.timeIntervalSince(coreDataLatestDate) <= AppConstants.Duration.isNightSleep * 60 * 60 {
            coreDataMostRecentDay.endDate = healthDataLatestDate

            let newSleepEntries = mapSleepEntriesToCoreData(healthDataLatestDay.entries, parent: coreDataMostRecentDay, context: context)
            coreDataMostRecentDay.addToSleepEntries(NSOrderedSet(array: newSleepEntries))
            
            let historicalData = Array(healthData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newSleepEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries.insert(contentsOf: newSleepEntries, at: 0)
        }
        
        return mergedEntries
    }
}

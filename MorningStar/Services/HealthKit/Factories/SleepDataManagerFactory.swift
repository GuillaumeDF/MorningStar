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
    
    static func mapHealthKitToCoreData(_ healthKitData: [SleepPeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        var periodEntries: [PeriodEntryMO] = []
        
        healthKitData.forEach { sleepPeriod in
            guard let startDate = sleepPeriod.entries.first?.startDate,
                  let endDate = sleepPeriod.entries.last?.endDate else {
                return
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = sleepPeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let sleepEntities: [SleepEntryMO] = sleepPeriod.entries.map { sleepEntry in
                let newEntry = SleepEntryMO(context: context)
                
                newEntry.id = sleepEntry.id
                newEntry.startDate = sleepEntry.startDate
                newEntry.endDate = sleepEntry.endDate
                newEntry.unit = sleepEntry.unit
                newEntry.periodEntry = periodEntity
                
                return newEntry
            }
            periodEntity.addToSleepEntries(NSOrderedSet(array: sleepEntities))
            periodEntries.append(periodEntity)
        }
        
        return periodEntries
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntry: [PeriodEntryMO]) -> [SleepPeriod] {
        return coreDataEntry.map { periodEntity in
            let sleepEntries: [HealthData.SleepEntry] = (periodEntity.sleepEntries)?.compactMap { entry in
                guard let sleepEntity = entry as? SleepEntryMO else {
                    return nil
                }
                
                return HealthData.SleepEntry(
                    id: sleepEntity.id ?? UUID(),
                    startDate: sleepEntity.startDate ?? Date(),
                    endDate: sleepEntity.endDate ?? Date(),
                    unit: sleepEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id ?? UUID(), entries: sleepEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntry: [PeriodEntryMO], with healthKitData: [SleepPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
        guard let coreDataMostRecentDay = coreDataEntry.first,
              let coreDataMostRecentDate = coreDataMostRecentDay.startDate,
              let coreDataLatestDate = coreDataEntry.last?.endDate else {
            return mapHealthKitToCoreData(healthKitData, context: context)
        }
        
        guard let healthKitMostRecentDate = healthKitData.first?.startDate,
              let healthKitLatestDay = healthKitData.last,
              let healthKitLatestDate = healthKitLatestDay.endDate,
              coreDataLatestDate <= healthKitMostRecentDate else {
            return coreDataEntry
        }
        
        var mergedEntries = coreDataEntry
        
        if healthKitMostRecentDate.timeIntervalSince(coreDataLatestDate) <= AppConstants.Duration.isNightSleep * 60 * 60 {
            coreDataMostRecentDay.endDate = healthKitLatestDate
            
            let newSleepEntries = mapHealthKitToCoreData([healthKitLatestDay], context: context).first?.sleepEntries ?? []
            
            coreDataMostRecentDay.addToSleepEntries(newSleepEntries)
            
            let historicalData = Array(healthKitData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newSleepEntries = mapHealthKitToCoreData(healthKitData, context: context)
            mergedEntries.insert(contentsOf: newSleepEntries, at: 0)
        }
        
        return mergedEntries
    }
}

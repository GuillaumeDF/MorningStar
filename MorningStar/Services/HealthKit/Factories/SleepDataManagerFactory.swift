//
//  SleepDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

// TODO: Public Constants ?
private enum Constants {
    static let isNightSleep: TimeInterval = 4
}

struct SleepDataManagerFactory: HealthDataFactoryProtocol {
    typealias HealthKitDataType = SleepPeriod
    typealias CoreDataType = PeriodEntryMO
    
    static var healthKitSampleType: HKSampleType? {
        HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)
    }
    
    static var id: HealthDataType {
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
        guard !healthKitData.isEmpty else {
            return coreDataEntry
        }
        
        guard !coreDataEntry.isEmpty else {
            return mapHealthKitToCoreData(healthKitData, context: context)
        }
        
        var mergedEntries = coreDataEntry
        guard let lastHealthKitNight = healthKitData.last,
              let firstCoreDataEntry = mergedEntries.first,
              let coreDataMostRecentNightEnd = firstCoreDataEntry.endDate,
              let timeDifference = lastHealthKitNight.startDate?.timeIntervalSince(coreDataMostRecentNightEnd)
        else {
            let newEntries = mapHealthKitToCoreData(healthKitData, context: context)
            mergedEntries.insert(contentsOf: newEntries, at: 0)
            return mergedEntries
        }
        
        if timeDifference < Constants.isNightSleep * 60 * 60 {
            firstCoreDataEntry.endDate = lastHealthKitNight.endDate
            
            let sleepEntries = lastHealthKitNight.entries.map { sleepEntry in
                let newEntry = SleepEntryMO(context: context)
                
                newEntry.id = sleepEntry.id
                newEntry.startDate = sleepEntry.startDate
                newEntry.endDate = sleepEntry.endDate
                newEntry.unit = sleepEntry.unit
                newEntry.periodEntry = firstCoreDataEntry
                
                return newEntry
            }
            
            firstCoreDataEntry.addToSleepEntries(NSOrderedSet(array: sleepEntries))
            
            let historicalData = Array(healthKitData.dropLast())
            
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newEntries = mapHealthKitToCoreData(healthKitData, context: context)
            mergedEntries.insert(contentsOf: newEntries, at: 0)
        }
        
        return mergedEntries
    }
}

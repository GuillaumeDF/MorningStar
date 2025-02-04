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
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[WeightPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[WeightPeriod]>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            HealthDataProcessor.groupWeightsByWeek(from: samples, unit: .gramUnit(with: .kilo))
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[WeightPeriod]>>? {
        nil
    }
    
    static func mapHealthKitToCoreData(_ healthKitData: [WeightPeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        var periodEntries: [PeriodEntryMO] = []
        
        healthKitData.forEach { weightPeriod in
            guard let startDate = weightPeriod.entries.first?.startDate,
                  let endDate = weightPeriod.entries.last?.endDate else {
                return
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = weightPeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let weightEntries: [WeightEntryMO] = weightPeriod.entries.map { weightEntry in
                let newEntry = WeightEntryMO(context: context)
                
                newEntry.id = weightEntry.id
                newEntry.startDate = weightEntry.startDate
                newEntry.endDate = weightEntry.endDate
                newEntry.value = weightEntry.value
                newEntry.unit = weightEntry.unit
                newEntry.periodEntry = periodEntity
                
                return newEntry
            }
            periodEntity.addToWeightEntries(NSOrderedSet(array: weightEntries))
            periodEntries.append(periodEntity)
        }
        
        return periodEntries
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntry: [PeriodEntryMO]) -> [WeightPeriod] {
        return coreDataEntry.map { periodEntity in
            let weightEntries: [HealthData.WeightEntry] = (periodEntity.weightEntries)?.compactMap { entry in
                guard let weightEntity = entry as? WeightEntryMO else {
                    return nil
                }
                
                return HealthData.WeightEntry(
                    id: weightEntity.id ?? UUID(),
                    startDate: weightEntity.startDate ?? Date(),
                    endDate: weightEntity.endDate ?? Date(),
                    value: weightEntity.value,
                    unit: weightEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id ?? UUID(), entries: weightEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntry: [PeriodEntryMO], with healthKitData: [WeightPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
        guard let coreDataMostRecentWeek = coreDataEntry.first,
              let coreDataMostRecentDay = coreDataMostRecentWeek.startDate,
              let coreDataLatestDay = coreDataEntry.last?.endDate else {
            return mapHealthKitToCoreData(healthKitData, context: context)
        }
        
        guard let healthKitMostRecentDay = healthKitData.first?.startDate,
              let healthKitLatestWeek = healthKitData.last,
              let healthKitLatestDay = healthKitLatestWeek.endDate,
              coreDataLatestDay <= healthKitMostRecentDay else {
            return coreDataEntry
        }
        
        let calendar = Calendar.current
        var mergedEntries = coreDataEntry
        
        if calendar.isDate(coreDataMostRecentDay, equalTo: healthKitLatestDay, toGranularity: .weekOfYear) {
            coreDataMostRecentWeek.endDate = healthKitLatestDay
            
            let newWeightEntries = mapHealthKitToCoreData([healthKitLatestWeek], context: context).first?.weightEntries ?? []
            
            coreDataMostRecentWeek.addToWeightEntries(newWeightEntries)
            
            let historicalData = Array(healthKitData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newWeightEntries = mapHealthKitToCoreData(healthKitData, context: context)
            mergedEntries.insert(contentsOf: newWeightEntries, at: 0)
        }
        
        return mergedEntries
    }
}

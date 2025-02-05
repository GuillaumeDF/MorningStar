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
    
    static func mapHealthKitToCoreData(_ healthData: [WeightPeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        var periodEntries: [PeriodEntryMO] = []
        
        healthData.forEach { weightPeriod in
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
    
    static func mapCoreDataToHealthKit(_ coreDataEntries: [PeriodEntryMO]) -> [WeightPeriod] {
        return coreDataEntries.map { periodEntity in
            let weightEntries: [HealthData.WeightEntry] = (periodEntity.weightEntries)?.compactMap { entry in
                guard let weightEntity = entry as? WeightEntryMO,
                      let startDate = weightEntity.startDate,
                      let endDate = weightEntity.endDate else {
                    return nil
                }
                
                return HealthData.WeightEntry(
                    id: weightEntity.id ?? UUID(),
                    startDate: startDate,
                    endDate: endDate,
                    value: weightEntity.value,
                    unit: weightEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id ?? UUID(), entries: weightEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [PeriodEntryMO], with healthData: [WeightPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
        guard let coreDataMostRecentWeek = coreDataEntries.first,
              let coreDataMostRecentDay = coreDataMostRecentWeek.startDate,
              let coreDataLatestDay = coreDataEntries.last?.endDate else {
            return mapHealthKitToCoreData(healthData, context: context)
        }
        
        guard let healthDataMostRecentDay = healthData.first?.startDate,
              let healthDataLatestWeek = healthData.last,
              let healthDataLatestDay = healthDataLatestWeek.endDate,
              coreDataLatestDay <= healthDataMostRecentDay else {
            return coreDataEntries
        }
        
        let calendar = Calendar.current
        var mergedEntries = coreDataEntries
        
        if calendar.isDate(coreDataMostRecentDay, equalTo: healthDataLatestDay, toGranularity: .weekOfYear) {
            coreDataMostRecentWeek.endDate = healthDataLatestDay
            
            guard let newWeightEntries = mapHealthKitToCoreData([healthDataLatestWeek], context: context).first?.weightEntries else {
                return coreDataEntries
            }
            
            coreDataMostRecentWeek.addToWeightEntries(newWeightEntries)
            
            let historicalData = Array(healthData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newWeightEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries.insert(contentsOf: newWeightEntries, at: 0)
        }
        
        return mergedEntries
    }
}

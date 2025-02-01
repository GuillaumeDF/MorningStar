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
    typealias HealthKitDataType = CaloriesPeriod
    typealias CoreDataType = PeriodEntryMO
    
    static var healthKitSampleType: HKSampleType? {
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
    }
    
    static var id: HealthDataType {
        .calories
    }
    
    static var predicateCoreData: NSPredicate? {
        NSPredicate(format: "calorieEntries.@count > 0")
    }
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[CaloriesPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[CaloriesPeriod]>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
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
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[CaloriesPeriod]>>? {
        let queryDescriptor = StatisticsCollectionQueryDescriptor<[PeriodEntry<HealthData.ActivityEntry>]>(
            quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            anchorDate: Calendar.current.startOfDay(for: startDate),
            intervalComponents: DateComponents(hour: 1),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            options: .cumulativeSum
        ) { statisticsCollection in
            HealthDataProcessor.groupActivitiesByDay(for: statisticsCollection, from: startDate, to: endDate, unit: HKUnit.kilocalorie())
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
    
    static func mapHealthKitToCoreData(_ healthKitData: [CaloriesPeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        var periodEntries: [PeriodEntryMO] = []
        
        healthKitData.forEach { caloriePeriod in
            guard let startDate = caloriePeriod.entries.first?.startDate,
                  let endDate = caloriePeriod.entries.last?.endDate else {
                return
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = caloriePeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let calorieEntries: [CalorieEntryMO] = caloriePeriod.entries.map { calorieEntry in
                let newEntry = CalorieEntryMO(context: context)
                
                newEntry.id = calorieEntry.id
                newEntry.startDate = calorieEntry.startDate
                newEntry.endDate = calorieEntry.endDate
                newEntry.value = calorieEntry.value
                newEntry.unit = calorieEntry.unit
                newEntry.periodEntry = periodEntity
                
                return newEntry
            }
            periodEntity.addToCalorieEntries(NSOrderedSet(array: calorieEntries))
            periodEntries.append(periodEntity)
        }
        
        return periodEntries
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntry: [PeriodEntryMO]) -> [CaloriesPeriod] {
        return coreDataEntry.map { periodEntity in
            let calorieEntries: [HealthData.ActivityEntry] = (periodEntity.calorieEntries)?.compactMap { entry in
                guard let calorieEntity = entry as? CalorieEntryMO else {
                    return nil
                }
                
                return HealthData.ActivityEntry(
                    id: calorieEntity.id ?? UUID(),
                    startDate: calorieEntity.startDate ?? Date(),
                    endDate: calorieEntity.endDate ?? Date(),
                    value: calorieEntity.value,
                    unit: calorieEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id ?? UUID(), entries: calorieEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntry: [PeriodEntryMO], with healthKitData: [CaloriesPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
        guard !healthKitData.isEmpty else {
            return coreDataEntry
        }
        
        guard !coreDataEntry.isEmpty else {
            return mapHealthKitToCoreData(healthKitData, context: context)
        }
        
        var mergedEntries = coreDataEntry
        guard let healthKitMostRecentDay = healthKitData.last?.endDate,
              let coreDataMostRecentDay = coreDataEntry.first?.startDate,
              let lastHealthKitDay = healthKitData.last,
              let firstCoreDataEntry = mergedEntries.first
        else {
            let newEntries = mapHealthKitToCoreData(healthKitData, context: context)
            
            mergedEntries.insert(contentsOf: newEntries, at: 0)
            
            return mergedEntries
        }
        
        if coreDataMostRecentDay.isSameDay(as: healthKitMostRecentDay) {
            firstCoreDataEntry.endDate = lastHealthKitDay.endDate
            
            let calorieEntries = lastHealthKitDay.entries.map { calorieEntry in
                let newEntry = CalorieEntryMO(context: context)
                
                newEntry.id = calorieEntry.id
                newEntry.startDate = calorieEntry.startDate
                newEntry.endDate = calorieEntry.endDate
                newEntry.value = calorieEntry.value
                newEntry.unit = calorieEntry.unit
                newEntry.periodEntry = firstCoreDataEntry
                
                return newEntry
            }
            
            firstCoreDataEntry.addToCalorieEntries(NSOrderedSet(array: calorieEntries))
            
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

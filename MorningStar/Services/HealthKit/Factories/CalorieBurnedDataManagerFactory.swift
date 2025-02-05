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
    typealias CoreDataType = PeriodEntryMO
    
    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        ]
    }
    
    static var id: HealthMetricType {
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
    
    static func mapHealthKitToCoreData(_ healthData: [CaloriesPeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        var periodEntries: [PeriodEntryMO] = []
        
        healthData.forEach { caloriePeriod in
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
    
    static func mapCoreDataToHealthKit(_ coreDataEntries: [PeriodEntryMO]) -> [CaloriesPeriod] {
        return coreDataEntries.map { periodEntity in
            let calorieEntries: [HealthData.ActivityEntry] = (periodEntity.calorieEntries)?.compactMap { entry in
                guard let calorieEntity = entry as? CalorieEntryMO,
                      let startDate = calorieEntity.startDate,
                      let endDate = calorieEntity.endDate else {
                    return nil
                }
                
                return HealthData.ActivityEntry(
                    id: calorieEntity.id,
                    startDate: startDate,
                    endDate: endDate,
                    value: calorieEntity.value,
                    unit: calorieEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id, entries: calorieEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [PeriodEntryMO], with healthData: [CaloriesPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
        guard  let coreDataMostRecentDay = coreDataEntries.first,
               let coreDataMostRecentDate = coreDataMostRecentDay.startDate,
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
        
        if coreDataMostRecentDate.isSameDay(as: healthDataLatestDate) {
            coreDataMostRecentDay.endDate = healthDataLatestDate

            guard let newCalorieEntries = mapHealthKitToCoreData([healthDataLatestDay], context: context).first?.calorieEntries else {
                return coreDataEntries
            }
            
            coreDataMostRecentDay.addToCalorieEntries(newCalorieEntries)
            
            let historicalData = Array(healthData.dropLast())
            
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newCalorieEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries.insert(contentsOf: newCalorieEntries, at: 0)
        }
        
        return mergedEntries
    }
}

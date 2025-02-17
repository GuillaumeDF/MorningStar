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
        var utcCalendar = Calendar.current // TODO: Créer un factory pour Calendar
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        let queryDescriptor = StatisticsCollectionQueryDescriptor<[PeriodEntry<HealthData.ActivityEntry>]>(
            quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            anchorDate: utcCalendar.startOfDay(for: startDate),
            intervalComponents: DateComponents(hour: 1),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            options: .cumulativeSum
        ) { statisticsCollection in
            HealthDataProcessor.groupActivitiesByDay(for: statisticsCollection, from: startDate, to: endDate, unit: HKUnit.kilocalorie())
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
    
    static func mapHealthKitToCoreData(_ healthData: [CaloriesPeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        healthData.compactMap { caloriePeriod in
            guard let startDate = caloriePeriod.entries.first?.startDate,
                  let endDate = caloriePeriod.entries.last?.endDate else {
                Logger.logWarning(id, message: "Can't retry startDate or endDate CaloriePeriod \(caloriePeriod.id)")
                return nil
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = caloriePeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let calorieEntities = mapCalorieEntriesToCoreData(caloriePeriod.entries, parent: periodEntity, context: context)
            periodEntity.addToCalorieEntries(NSOrderedSet(array: calorieEntities))
            
            return periodEntity
        }
    }
    
    private static func mapCalorieEntriesToCoreData(_ calorieEntries: [HealthData.ActivityEntry],
                                                 parent: PeriodEntryMO,
                                                 context: NSManagedObjectContext) -> [CalorieEntryMO] {
        calorieEntries.map { calorieEntry in
            let newCalorieEntity = CalorieEntryMO(context: context)
            
            newCalorieEntity.id = calorieEntry.id
            newCalorieEntity.startDate = calorieEntry.startDate
            newCalorieEntity.endDate = calorieEntry.endDate
            newCalorieEntity.value = calorieEntry.value
            newCalorieEntity.unit = calorieEntry.unit
            newCalorieEntity.periodEntry = parent
            
            return newCalorieEntity
        }
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

        if mostRecentCoreDataEndDate.isSameDay(as: oldestHealthDataStartDate) {
            Logger.logInfo(id, message: "Updating most recent CoreData entry with HealthKit data")
            mostRecentCoreDataEntry.endDate =  oldestHealthDataEndDate

            let newCalorieEntries = mapCalorieEntriesToCoreData(oldestHealthDataEntry.entries, parent: mostRecentCoreDataEntry, context: context)
            mostRecentCoreDataEntry.addToCalorieEntries(NSOrderedSet(array: newCalorieEntries))

            let historicalData = Array(healthData.dropLast())
            if !historicalData.isEmpty {
                Logger.logInfo(id, message: "Adding historical HealthKit data to CoreData")
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            Logger.logInfo(id, message: "Mapping all HealthKit data to CoreData")
            let newCalorieEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries.insert(contentsOf: newCalorieEntries, at: 0)
        }

        Logger.logInfo(id, message: "Merge process completed")
        return mergedEntries
    }
}

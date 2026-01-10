//
//  StepDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

struct StepDataManagerFactory: HealthDataFactoryProtocol {
    typealias HealthDataType = StepPeriod
    typealias CoreDataType = PeriodEntryMO
    
    static var requiredHealthKitAuthorizationType: [HKSampleType?] {
        [
            HKQuantityType.quantityType(forIdentifier: .stepCount)
        ]
    }
    
    static var id: HealthMetricType {
        .steps
    }
    
    static var predicateCoreData: NSPredicate? {
        NSPredicate(format: "stepEntries.@count > 0")
    }
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<SampleQueryDescriptor<[StepPeriod]>>? {
        let queryDescriptor = SampleQueryDescriptor<[StepPeriod]>(
            sampleType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        ) { samples in
            HealthDataProcessor.groupActivitiesByDay(from: samples, unit: HKUnit.count())
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[StepPeriod]>>? {
        var utcCalendar = Calendar.current
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        let queryDescriptor = StatisticsCollectionQueryDescriptor<[StepPeriod]>(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            anchorDate: utcCalendar.startOfDay(for: startDate),
            intervalComponents: DateComponents(hour: 1),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate]),
            options: .cumulativeSum
        ) { statisticsCollection in
            HealthDataProcessor.groupActivitiesByDay(for: statisticsCollection, from: startDate, to: endDate ?? Date(), unit: HKUnit.count()) // TODO: A verifier
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
    
    static func mapHealthKitToCoreData(_ healthData: [HealthDataType], context: NSManagedObjectContext) -> [CoreDataType] {
        healthData.compactMap { stepPeriod in
            guard let startDate = stepPeriod.entries.first?.startDate,
                  let endDate = stepPeriod.entries.last?.endDate else {
                Logger.logWarning(id, message: "Can't retry startDate or endDate StepPeriod \(stepPeriod.id)")
                return nil
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = stepPeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let stepEntities = mapStepEntriesToCoreData(stepPeriod.entries, parent: periodEntity, context: context)
            periodEntity.addToStepEntries(NSOrderedSet(array: stepEntities))
            
            return periodEntity
        }
    }
    
    private static func mapStepEntriesToCoreData(_ stepEntries: [HealthData.ActivityEntry],
                                                 parent: PeriodEntryMO,
                                                 context: NSManagedObjectContext) -> [StepEntryMO] {
        stepEntries.map { stepEntry in
            let newStepEntity = StepEntryMO(context: context)
            
            newStepEntity.id = stepEntry.id
            newStepEntity.startDate = stepEntry.startDate
            newStepEntity.endDate = stepEntry.endDate
            newStepEntity.value = stepEntry.value
            newStepEntity.unit = stepEntry.unit
            newStepEntity.periodEntry = parent
            
            return newStepEntity
        }
    }
    
    static func mapCoreDataToHealthKit(_ coreDataEntries: [PeriodEntryMO]) -> [StepPeriod] {
        return coreDataEntries.map { periodEntity in
            let stepEntries: [HealthData.ActivityEntry] = (periodEntity.stepEntries)?.compactMap { entry in
                guard let stepEntity = entry as? StepEntryMO,
                      let startDate = stepEntity.startDate,
                      let endDate = stepEntity.endDate else {
                    return nil
                }
                
                return HealthData.ActivityEntry(
                    id: stepEntity.id,
                    startDate: startDate,
                    endDate: endDate,
                    value: stepEntity.value,
                    unit: stepEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id, entries: stepEntries)
        }
    }
    

    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [PeriodEntryMO], with healthData: [StepPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
        Logger.logInfo(id, message: "Starting merge process with coreData entries an healthData entries")
        guard let mostRecentCoreDataEntry = coreDataEntries.first,
              let mostRecentCoreDataEndDate = mostRecentCoreDataEntry.endDate else {
            Logger.logWarning(id, message: "CoreData entries are empty or invalid, mapping HealthKit data to CoreData")
            return mapHealthKitToCoreData(healthData, context: context)
        }
        
        guard var oldestHealthDataEntry = healthData.last,
              let oldestHealthDataEndDate = oldestHealthDataEntry.endDate,
              let oldestHealthDataStartDate = oldestHealthDataEntry.startDate else {
            Logger.logWarning(id, message: "HealthKit entries are empty or invalid, mapping HealthKit data to CoreData")
            return coreDataEntries
        }
        
        var mergedEntries = coreDataEntries

        if mostRecentCoreDataEndDate.isSameDay(as: oldestHealthDataStartDate) {
            Logger.logInfo(id, message: "Updating most recent CoreData entry with HealthKit data")
            mostRecentCoreDataEntry.endDate = oldestHealthDataEndDate

            if mostRecentCoreDataEndDate.minutesBetween(and: oldestHealthDataStartDate) <= 5,
               let mostRecentCoreDateStepEntry = mostRecentCoreDataEntry.stepEntries?.lastObject as? StepEntryMO,
               let oldestHealthDataStepEntry = oldestHealthDataEntry.entries.first {
                mostRecentCoreDateStepEntry.endDate = oldestHealthDataStepEntry.endDate
                mostRecentCoreDateStepEntry.value += oldestHealthDataStepEntry.value

                oldestHealthDataEntry.entries = Array(oldestHealthDataEntry.entries.dropFirst())
            }
            if mostRecentCoreDataEndDate.minutesBetween(and: oldestHealthDataStartDate) > 5,
               let mostRecentCoreDateStepEntry = mostRecentCoreDataEntry.stepEntries?.lastObject as? StepEntryMO,
               let oldestHealthDataStepEntry = oldestHealthDataEntry.entries.first {
                let placeholderStepEntry = HealthData.ActivityEntry(startDate: mostRecentCoreDateStepEntry.endDate!, endDate: oldestHealthDataStepEntry.startDate, value: 0, unit: mostRecentCoreDateStepEntry.unit!)

                oldestHealthDataEntry.entries = [placeholderStepEntry] + oldestHealthDataEntry.entries
            }

            let newStepEntries = mapStepEntriesToCoreData(oldestHealthDataEntry.entries, parent: mostRecentCoreDataEntry, context: context)
            mostRecentCoreDataEntry.addToStepEntries(NSOrderedSet(array: newStepEntries))

            let historicalData = Array(healthData.dropLast())
            if !historicalData.isEmpty {
                Logger.logInfo(id, message: "Adding historical HealthKit data to CoreData")
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries = historicalEntries + mergedEntries
            }
        } else {
            Logger.logInfo(id, message: "Mapping all HealthKit data to CoreData")
            let newStepEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries = newStepEntries + mergedEntries
        }

        Logger.logInfo(id, message: "Merge process completed")
        return mergedEntries
    }
}

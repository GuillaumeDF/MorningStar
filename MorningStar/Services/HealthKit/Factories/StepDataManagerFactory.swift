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
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[StepPeriod]>>? {
        nil
    }
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[StepPeriod]>>? {
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        let queryDescriptor = StatisticsCollectionQueryDescriptor<[StepPeriod]>(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            anchorDate: utcCalendar.startOfDay(for: startDate),
            intervalComponents: DateComponents(hour: 1),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            options: .cumulativeSum
        ) { statisticsCollection in
            HealthDataProcessor.groupActivitiesByDay(for: statisticsCollection, from: startDate, to: endDate, unit: HKUnit.count())
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
            
            let newStepEntries = mapStepEntriesToCoreData(healthDataLatestDay.entries, parent: coreDataMostRecentDay, context: context)
            coreDataMostRecentDay.addToStepEntries(NSOrderedSet(array: newStepEntries))
            
            let historicalData = Array(healthData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            let newStepEntries = mapHealthKitToCoreData(healthData, context: context)
            mergedEntries.insert(contentsOf: newStepEntries, at: 0)
        }
        
        return mergedEntries
    }
}

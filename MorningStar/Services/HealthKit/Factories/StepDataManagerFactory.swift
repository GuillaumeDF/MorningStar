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
    typealias HealthKitDataType = StepPeriod
    typealias CoreDataType = PeriodEntryMO
    
    static var healthKitSampleType: HKSampleType? {
        HKQuantityType.quantityType(forIdentifier: .stepCount)
    }
    
    static var id: HealthDataType {
        .steps
    }
    
    static var predicateCoreData: NSPredicate? {
        NSPredicate(format: "stepEntries.@count > 0")
    }
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[StepPeriod]>>? {
        nil
    }
    
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[StepPeriod]>>? {
        let queryDescriptor = StatisticsCollectionQueryDescriptor<[StepPeriod]>(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            anchorDate: Calendar.current.startOfDay(for: startDate),
            intervalComponents: DateComponents(hour: 1),
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
            options: .cumulativeSum
        ) { statisticsCollection in
            HealthDataProcessor.groupActivitiesByDay(for: statisticsCollection, from: startDate, to: endDate, unit: HKUnit.count())
        }
        
        return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
    }
    
    static func transformHealthKitToCoreData(_ healthKitData: [StepPeriod], context: NSManagedObjectContext) {
        healthKitData.forEach { stepPeriod in
            guard let startDate = stepPeriod.entries.first?.startDate,
                  let endDate = stepPeriod.entries.last?.endDate else {
                return
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = stepPeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let stepEntries: [StepEntryMO] = stepPeriod.entries.map { stepEntry in
                let newEntry = StepEntryMO(context: context)
                
                newEntry.id = stepEntry.id
                newEntry.startDate = stepEntry.startDate
                newEntry.endDate = stepEntry.endDate
                newEntry.value = stepEntry.value
                newEntry.unit = stepEntry.unit
                newEntry.periodEntry = periodEntity
                
                return newEntry
            }
            periodEntity.addToStepEntries(NSOrderedSet(array: stepEntries))
        }
    }
    
    static func transformCoreDataToHealthKit(_ coreDataEntry: [PeriodEntryMO]) -> [StepPeriod] {
        return coreDataEntry.map { periodEntity in
            let stepEntries: [HealthData.ActivityEntry] = (periodEntity.stepEntries)?.compactMap { entry in
                guard let stepEntity = entry as? StepEntryMO else {
                    return nil
                }
                
                return HealthData.ActivityEntry(
                    id: stepEntity.id ?? UUID(),
                    startDate: stepEntity.startDate ?? Date(),
                    endDate: stepEntity.endDate ?? Date(),
                    value: stepEntity.value,
                    unit: stepEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(entries: stepEntries)
        }
    }
}

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
    
    static func mapHealthKitToCoreData(_ healthData: [HealthDataType], context: NSManagedObjectContext) -> [CoreDataType] {
        var periodEntries: [PeriodEntryMO] = []
        
        healthData.forEach { stepPeriod in
            guard let startDate = stepPeriod.entries.first?.startDate,
                  let endDate = stepPeriod.entries.last?.endDate else {
                print("Can't get start or end date from StepPeriod")
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
            periodEntries.append(periodEntity)
        }
        
        return periodEntries
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
                    id: stepEntity.id ?? UUID(),
                    startDate: startDate,
                    endDate: endDate,
                    value: stepEntity.value,
                    unit: stepEntity.unit ?? ""
                )
            } ?? []
            
            return PeriodEntry(id: periodEntity.id ?? UUID(), entries: stepEntries)
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
            
            guard let newStepEntries = mapHealthKitToCoreData([healthDataLatestDay], context: context).first?.stepEntries else {
                return coreDataEntries
            }
            
            coreDataMostRecentDay.addToStepEntries(newStepEntries)
            
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

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        
        let day1 = formatter.string(from: self)
        let day2 = formatter.string(from: otherDate)
        
        return day1 == day2
    }
}

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
    
    static func mapHealthKitToCoreData(_ healthKitData: [HealthKitDataType], context: NSManagedObjectContext) -> [CoreDataType] {
        var periodEntries: [PeriodEntryMO] = []
        
        healthKitData.forEach { stepPeriod in
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
    
    static func mapCoreDataToHealthKit(_ coreDataEntry: [PeriodEntryMO]) -> [StepPeriod] {
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
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntry: [PeriodEntryMO], with healthKitData: [StepPeriod], in context: NSManagedObjectContext) -> [PeriodEntryMO] {
        guard !healthKitData.isEmpty else {
            return coreDataEntry
        }
        
        guard !coreDataEntry.isEmpty else {
            return mapHealthKitToCoreData(healthKitData, context: context)
        }
        
        var mergedEntries = coreDataEntry
        guard let healthKitMostRecentDay = healthKitData.last?.startDate,
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
            
            let stepEntries = lastHealthKitDay.entries.map { stepEntry in
                let newEntry = StepEntryMO(context: context)
                
                newEntry.id = stepEntry.id
                newEntry.startDate = stepEntry.startDate
                newEntry.endDate = stepEntry.endDate
                newEntry.value = stepEntry.value
                newEntry.unit = stepEntry.unit
                newEntry.periodEntry = firstCoreDataEntry
                
                return newEntry
            }
            
            firstCoreDataEntry.addToStepEntries(NSOrderedSet(array: stepEntries))
            
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

func arePeriodEntriesConsistent(_ periods: [PeriodEntryMO]) -> Bool {
    for (index, period) in periods.enumerated() {
        guard let periodStartDate = period.startDate, let periodEndDate = period.endDate else {
            print("Erreur : Une période n'a pas de dates valides.")
            return false
        }

        // Vérification de l'ordre des périodes principales
        if index > 0 {
            let previousPeriod = periods[index - 1]
            if let previousStartDate = previousPeriod.startDate {
                if periodStartDate > previousStartDate {
                    print("Incohérence : La période \(periodStartDate) est après \(previousStartDate).")
                    return false
                }
            }
        }

        // Vérification des entrées internes
        let entries = period.stepEntries?.compactMap { $0 as? StepEntryMO } ?? []
        for (subIndex, entry) in entries.enumerated() {
            guard let entryStartDate = entry.startDate, let entryEndDate = entry.endDate else {
                print("[\(index)][\(subIndex)]")
                print("Erreur : Une entrée interne n'a pas de dates valides.")
                return false
            }

            // Vérification que l'entrée est bien contenue dans sa période principale
            if entryStartDate < periodStartDate || entryEndDate > periodEndDate {
                print("[\(index)][\(subIndex)]")
                print("Incohérence : L'entrée (\(entryStartDate) - \(entryEndDate)) dépasse la période principale (\(periodStartDate) - \(periodEndDate)).")
                for entry in entries {
                    print(entry)
                }
                return false
            }

            // Vérification du tri interne des entrées
            if subIndex > 0 {
                let previousEntry = entries[subIndex - 1]
                if let previousStartDate = previousEntry.startDate {
                    if entryStartDate < previousStartDate {
                        print("[\(index)][\(subIndex)]")
                        print("Incohérence : L'entrée interne \(entryStartDate) est après \(previousStartDate).")
                        return false
                    }
                }
            }
        }
    }
    
    print("Le tableau de [PeriodEntryMO] ainsi ques les entrées de Steps sont correct")
    return true
}

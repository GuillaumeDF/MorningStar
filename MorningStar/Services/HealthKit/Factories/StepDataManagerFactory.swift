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
    
    static var healthKitSampleType: HKSampleType? {
        HKQuantityType.quantityType(forIdentifier: .stepCount)
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
    
    static func mapHealthKitToCoreData(_ healthKitData: [HealthDataType], context: NSManagedObjectContext) -> [CoreDataType] {
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
            
            return PeriodEntry(id: periodEntity.id ?? UUID(), entries: stepEntries)
        }
    }
    
    static func mergeCoreDataWithHealthKitData(
        _ coreDataEntry: [PeriodEntryMO],
        with healthKitData: [StepPeriod],
        in context: NSManagedObjectContext
    ) -> [PeriodEntryMO] {
        // Si pas de données Core Data, on convertit simplement les données HealthKit
        guard  let coreDataMostRecentDay = coreDataEntry.first,
            let coreDataMostRecentDate = coreDataMostRecentDay.startDate,
              let coreDataLatestDate = coreDataEntry.last?.endDate else {
            return mapHealthKitToCoreData(healthKitData, context: context)
        }
        
        // Vérification des données HealthKit et de leur chronologie
        guard let healthKitMostRecentDate = healthKitData.first?.startDate,
              let healthKitLatestDay = healthKitData.last,
              let healthKitLatestDate = healthKitLatestDay.endDate,
              coreDataLatestDate <= healthKitMostRecentDate else {
            return coreDataEntry
        }
        
        var mergedEntries = coreDataEntry
        
        // Si les données concernent le même jour
        if coreDataMostRecentDate.isSameDay(as: healthKitLatestDate) {
            // Mise à jour de la date de fin
            coreDataMostRecentDay.endDate = healthKitLatestDate
            
            // Création des nouvelles entrées de pas
            let newStepEntries = mapHealthKitToCoreData([healthKitLatestDay], context: context).first?.stepEntries ?? []
            
            // Ajout des nouvelles entrées
            coreDataMostRecentDay.addToStepEntries(newStepEntries)
            
            // Traitement des données historiques si présentes
            let historicalData = Array(healthKitData.dropLast())
            if !historicalData.isEmpty {
                let historicalEntries = mapHealthKitToCoreData(historicalData, context: context)
                mergedEntries.insert(contentsOf: historicalEntries, at: 0)
            }
        } else {
            // Si les jours sont différents, on ajoute simplement les nouvelles données
            let newStepEntries = mapHealthKitToCoreData(healthKitData, context: context)
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

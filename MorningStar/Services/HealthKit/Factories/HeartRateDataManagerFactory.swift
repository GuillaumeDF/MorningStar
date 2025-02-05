//
//  HeartRateDataManagerFactory.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation
import HealthKit
import CoreData

struct HeartRateDataManagerFactory {
    typealias HealthDataType = HeartRatePeriod
    typealias CoreDataType = PeriodEntryMO
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[HeartRatePeriod]>>? {
           let queryDescriptor = SampleQueryDescriptor<[HeartRatePeriod]>(
               sampleType: HKQuantityType.quantityType(forIdentifier: .heartRate)!,
               predicate: HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate]),
               limit: HKObjectQueryNoLimit,
               sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
           ) { samples in
               let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
   
               let heartRateEntries: [HealthData.HeartRateEntry] = samples.compactMap { sample in
                   guard let quantitySample = sample as? HKQuantitySample else { return nil }
                   let heartRateValue = quantitySample.quantity.doubleValue(for: heartRateUnit)
   
                   return HealthData.HeartRateEntry(
                       startDate: quantitySample.startDate,
                       endDate: quantitySample.endDate,
                       value: heartRateValue
                   )
               }
   
               let heartRates = PeriodEntry<HealthData.HeartRateEntry>(entries: heartRateEntries)
   
               return [heartRates]
           }
   
           return HealthDataManager(healthStore: healthStore, queryDescriptor: queryDescriptor)
       }
    
    static func mapHealthKitToCoreData(_ healthData: [HeartRatePeriod], context: NSManagedObjectContext) -> [PeriodEntryMO] {
        var periodEntries: [PeriodEntryMO] = []
        
        healthData.forEach { heartRatePeriod in
            guard let startDate = heartRatePeriod.entries.first?.startDate,
                  let endDate = heartRatePeriod.entries.last?.endDate else {
                return
            }
            
            let periodEntity = PeriodEntryMO(context: context)
            
            periodEntity.id = heartRatePeriod.id
            periodEntity.startDate = startDate
            periodEntity.endDate = endDate
            
            let heartRateEntries: [HeartRateEntryMO] = heartRatePeriod.entries.map { heartRateEntry in
                let newEntry = HeartRateEntryMO(context: context)
                
                newEntry.id = heartRateEntry.id
                newEntry.startDate = heartRateEntry.startDate
                newEntry.endDate = heartRateEntry.endDate
                newEntry.value = heartRateEntry.value
                newEntry.unit = heartRateEntry.unit
                newEntry.periodEntry = periodEntity
                
                return newEntry
            }
            
            periodEntity.addToHeartRateEntries(NSOrderedSet(array: heartRateEntries))
            periodEntries.append(periodEntity)
        }
        
        return periodEntries
    }
    
     static func mapCoreDataToHealthKit(_ coreDataEntries: [PeriodEntryMO]) -> [HeartRatePeriod] {
         return coreDataEntries.map { periodEntity in
             let heartRateEntries: [HealthData.HeartRateEntry] = (periodEntity.heartRateEntries)?.compactMap { entry in
                 guard let heartRateEntity = entry as? HeartRateEntryMO else {
                     return nil
                 }
                 
                 return HealthData.HeartRateEntry(
                     id: heartRateEntity.id ?? UUID(),
                     startDate: heartRateEntity.startDate ?? Date(),
                     endDate: heartRateEntity.endDate ?? Date(),
                     value: heartRateEntity.value
                 )
             } ?? []
             
             return PeriodEntry(entries: heartRateEntries)
         }
     }
}

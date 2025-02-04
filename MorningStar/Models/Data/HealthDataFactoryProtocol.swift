//
//  HealthDataFactoryProtocol.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import CoreData
import HealthKit

protocol HealthDataFactoryProtocol {
    associatedtype HealthDataType // TODO: Rename
    associatedtype CoreDataType: NSManagedObject
    
    static var healthKitSampleType: HKSampleType? { get }
    static var id: HealthMetricType { get }
    static var predicateCoreData: NSPredicate? { get }
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[HealthDataType]>>?
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[HealthDataType]>>?
    
    static func mapHealthKitToCoreData(_ healthKitData: [HealthDataType], context: NSManagedObjectContext) -> [CoreDataType]
    static func mapCoreDataToHealthKit(_ coreDataEntry: [CoreDataType]) -> [HealthDataType]
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntry: [CoreDataType], with healthKitData: [HealthDataType], in context: NSManagedObjectContext) -> [CoreDataType]
}

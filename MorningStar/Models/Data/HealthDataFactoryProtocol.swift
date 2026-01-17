//
//  HealthDataFactoryProtocol.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import CoreData
import HealthKit

protocol HealthDataFactoryProtocol {
    associatedtype HealthDataType
    associatedtype CoreDataType: NSManagedObject

    static var requiredHealthKitAuthorizationType: [HKSampleType?] { get }
    static var id: HealthMetricType { get }

    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<SampleQueryDescriptor<[HealthDataType]>>?
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date?) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[HealthDataType]>>?

    static func mapHealthKitToCoreData(_ healthData: [HealthDataType], context: NSManagedObjectContext) -> [CoreDataType]
    static func mapCoreDataToHealthKit(_ coreDataEntries: [CoreDataType]) -> [HealthDataType]

    static func mergeCoreDataWithHealthKitData(_ coreDataEntries: [CoreDataType], with healthData: [HealthDataType], in context: NSManagedObjectContext) -> [CoreDataType]
}

//
//  HealthDataType.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import CoreData
import HealthKit

protocol HealthDataFactoryProtocol {
    associatedtype HealthKitDataType // TODO: Rename
    associatedtype CoreDataType: NSManagedObject
    
    static var healthKitSampleType: HKSampleType? { get }
    static var id: HealthDataType { get }
    static var predicateCoreData: NSPredicate? { get }
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[HealthKitDataType]>>?
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[HealthKitDataType]>>?
    
    static func mapHealthKitToCoreData(_ healthKitData: [HealthKitDataType], context: NSManagedObjectContext) -> [CoreDataType]
    static func mapCoreDataToHealthKit(_ coreDataEntry: [CoreDataType]) -> [HealthKitDataType]
    
    static func mergeCoreDataWithHealthKitData(_ coreDataEntry: [CoreDataType], with healthKitData: [HealthKitDataType], in context: NSManagedObjectContext) -> [CoreDataType]
}

// TODO: Verifier l'autorisation de heartRate
enum HealthDataType: CaseIterable, CustomStringConvertible {
    case steps
    case calories
    case weight
    case sleep
    case workouts
    //case heartRate
    
    var description: String {
        switch self {
        case .steps: return "steps"
        case .calories: return "calories"
        case .weight: return "weight"
        case .sleep: return "sleep"
        case .workouts: return "workouts"
            //case .heartRate: return "heartRate"
        }
    }
    
    var healthKitFactory: any HealthDataFactoryProtocol.Type {
        switch self {
        case .steps: return StepDataManagerFactory.self
        case .calories: return CalorieBurnedDataManagerFactory.self
        case .weight: return WeightDataManagerFactory.self
        case .sleep: return SleepDataManagerFactory.self
        case .workouts: return WorkoutDataManagerFactory.self
            //case .heartRate: return HeartRateDataManagerFactory.self // TODO: A vérifier
        }
    }
}

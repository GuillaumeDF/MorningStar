//
//  HealthKitSource.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import Foundation
import HealthKit

protocol HealthKitSourceProtocol {
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date) async throws -> [T.HealthDataType]
}

class HealthKitSource: HealthKitSourceProtocol {
    private let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }
    
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date) async throws -> [T.HealthDataType] {
       switch factory.id {
       case .workouts, .sleep, .weight:
           guard let manager = factory.createSampleQueryManager(
               for: healthStore,
               from: startDate,
               to: Date()
           ) else {
               throw HealthKitError.healthKitManagerInitializationFailure
           }
               
           return try await manager.fetchData()
           
       case .steps, .calories:
           guard let manager = factory.createStatisticsQueryManager(
               for: healthStore,
               from: startDate,
               to: Date()
           ) else {
               throw HealthKitError.healthKitManagerInitializationFailure
           }
               
           return try await manager.fetchData()
       }
    }
}

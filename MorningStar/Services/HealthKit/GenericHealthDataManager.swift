//
//  GenericHealthDataManager.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/10/2024.
//

import Foundation
import HealthKit

protocol HealthDataManageable {
    associatedtype QueryDescriptorType: QueryDescriptor
    
    var healthStore: HKHealthStore { get }
    var queryDescriptor: QueryDescriptorType { get }
    
    func fetchData() async throws -> QueryDescriptorType.ResultType
}

extension HealthDataManageable {
    func fetchData() async throws -> QueryDescriptorType.ResultType {
        return try await withCheckedThrowingContinuation { continuation in
            let query = queryDescriptor.createQuery { result in
                continuation.resume(with: result)
            }
            healthStore.execute(query)
        }
    }
}

class HealthDataManager<T: QueryDescriptor>: HealthDataManageable {
    typealias QueryDescriptorType = T
    
    let healthStore: HKHealthStore
    let queryDescriptor: T
    
    init(healthStore: HKHealthStore, queryDescriptor: T) {
        self.healthStore = healthStore
        self.queryDescriptor = queryDescriptor
    }
}

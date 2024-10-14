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
    
    func fetchData(completion: @escaping (Result<QueryDescriptorType.ResultType, Error>) -> Void)
}

extension HealthDataManageable {
    func fetchData(completion: @escaping (Result<QueryDescriptorType.ResultType, Error>) -> Void) {
        let query = queryDescriptor.createQuery(completion: completion)
        healthStore.execute(query)
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

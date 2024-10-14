//
//  QueryDescriptor.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/10/2024.
//

import Foundation
import HealthKit

protocol QueryDescriptor {
    associatedtype ResultType
    func createQuery(completion: @escaping (Result<ResultType, Error>) -> Void) -> HKQuery
}

// MARK: - Specific Query Descriptors

struct SampleQueryDescriptor<T>: QueryDescriptor {
    typealias ResultType = T
    
    let sampleType: HKSampleType
    let predicate: NSPredicate?
    let limit: Int
    let sortDescriptors: [NSSortDescriptor]?
    let resultsHandler: ([HKSample]) -> T?
    
    func createQuery(completion: @escaping (Result<T, Error>) -> Void) -> HKQuery {
        return HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { _, samples, error in
            if let error = error {
                completion(.failure(HealthKitError.queryFailed(error)))
            } else if let samples = samples, let processedResults = self.resultsHandler(samples) {
                completion(.success(processedResults))
            } else {
                completion(.failure(HealthKitError.dataProcessingFailed))
            }
        }
    }
}

struct StatisticsCollectionQueryDescriptor<T>: QueryDescriptor {
    typealias ResultType = T
    
    let quantityType: HKQuantityType
    let anchorDate: Date
    let intervalComponents: DateComponents
    let predicate: NSPredicate?
    let options: HKStatisticsOptions
    let resultsHandler: (HKStatisticsCollection) -> T?
    
    func createQuery(completion: @escaping (Result<T, Error>) -> Void) -> HKQuery {
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )
        
        query.initialResultsHandler = { _, results, error in
            if let error = error {
                completion(.failure(HealthKitError.queryFailed(error)))
            } else if let statisticsCollection = results, let processedResults = self.resultsHandler(statisticsCollection) {
                completion(.success(processedResults))
            } else {
                completion(.failure(HealthKitError.dataProcessingFailed))
            }
        }
        
        return query
    }
}

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

struct SampleQueryDescriptor<T>: QueryDescriptor {
    typealias ResultType = T
    
    let sampleType: HKSampleType
    let predicate: NSPredicate?
    let limit: Int
    let sortDescriptors: [NSSortDescriptor]?
    let resultsHandler: ([HKSample]) async -> T?
    
    func createQuery(completion: @escaping (Result<T, Error>) -> Void) -> HKQuery {
        return HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { _, samples, error in
            if let error = error {
                completion(.failure(HealthKitError.queryExecutionFailure(error)))
            } else if let samples = samples {
                Task {
                    let processedResults = await self.resultsHandler(samples)
                    if let processedResults = processedResults {
                        completion(.success(processedResults))
                    } else {
                        completion(.failure(HealthKitError.dataProcessingFailure))
                    }
                }
            } else {
                completion(.failure(HealthKitError.dataProcessingFailure))
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
    let resultsHandler: (HKStatisticsCollection) async -> T?
    
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
                completion(.failure(HealthKitError.queryExecutionFailure(error)))
            } else if let statisticsCollection = results {
                Task {
                    let processedResults = await self.resultsHandler(statisticsCollection)
                    if let processedResults = processedResults {
                        completion(.success(processedResults))
                    } else {
                        completion(.failure(HealthKitError.dataProcessingFailure))
                    }
                }
            } else {
                completion(.failure(HealthKitError.dataProcessingFailure))
            }
        }
        
        return query
    }
}

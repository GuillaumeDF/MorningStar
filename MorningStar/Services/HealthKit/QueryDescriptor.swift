//
//  QueryDescriptor.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/10/2024.
//

import Foundation
import HealthKit

protocol QueryDescriptor: Sendable {
    associatedtype ResultType: Sendable
    func createQuery(completion: @escaping @Sendable (Result<ResultType, Error>) -> Void) -> HKQuery
}

struct SampleQueryDescriptor<T: Sendable>: QueryDescriptor {
    typealias ResultType = T

    let sampleType: HKSampleType
    /// HealthKit predicates are immutable after creation, safe to access across isolation boundaries.
    nonisolated(unsafe) let predicate: NSPredicate?
    let limit: Int
    /// Sort descriptors are effectively immutable value semantics despite being reference types.
    nonisolated(unsafe) let sortDescriptors: [NSSortDescriptor]?
    let resultsHandler: @Sendable ([HKSample]) async -> T?

    func createQuery(completion: @escaping @Sendable (Result<T, Error>) -> Void) -> HKQuery {
        // Capture handler before Task to avoid unsafe self capture
        let handler = resultsHandler

        return HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { _, samples, error in
            if let error = error {
                completion(.failure(HealthKitError.queryExecutionFailure(error)))
            } else if let samples = samples {
                // Use detached task to avoid inheriting callback's execution context
                Task.detached {
                    let processedResults = await handler(samples)
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

struct StatisticsCollectionQueryDescriptor<T: Sendable>: QueryDescriptor {
    typealias ResultType = T

    let quantityType: HKQuantityType
    let anchorDate: Date
    let intervalComponents: DateComponents
    /// HealthKit predicates are immutable after creation, safe to access across isolation boundaries.
    nonisolated(unsafe) let predicate: NSPredicate?
    let options: HKStatisticsOptions
    let resultsHandler: @Sendable (HKStatisticsCollection) async -> T?

    func createQuery(completion: @escaping @Sendable (Result<T, Error>) -> Void) -> HKQuery {
        // Capture handler before Task to avoid unsafe self capture
        let handler = resultsHandler

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
                // Use detached task to avoid inheriting callback's execution context
                Task.detached {
                    let processedResults = await handler(statisticsCollection)
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

//
//  HealthKitAuthorizationManager.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import HealthKit

class HealthKitAuthorizationManager {
    private let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }
    
    func requestAuthorization() async throws {
        let typesToRead: Set<HKSampleType> = Set(
            HealthMetricType.allCases.flatMap { $0.healthKitFactory.requiredHealthKitAuthorizationType }
                .compactMap { $0 }
        )
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? HealthKitError.authorizationDenied)
                }
            }
        }
    }
}

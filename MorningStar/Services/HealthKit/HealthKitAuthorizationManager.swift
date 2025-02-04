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
        let typesToRead: Set<HKSampleType> = Set(HealthDataType.allCases.compactMap { $0.healthKitFactory.healthKitSampleType })
            .union([HKQuantityType.quantityType(forIdentifier: .heartRate)!]) // TODO: Temporaire autorisation pour HR
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? HealthError.authorizationDenied)
                }
            }
        }
    }
}

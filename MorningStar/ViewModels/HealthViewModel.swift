//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import Foundation
import HealthKit

class HealthViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    
    @Published var healthData: HealthData?
    @Published var authorizationStatus: Bool = false

    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let typesToRead: Set = [stepType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.authorizationStatus = success
                if success {
                    self.fetchStepCount()
                }
            }
        }
    }
    
    func fetchStepCount() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.healthData = HealthData(stepCount: 0.0)
                }
                return
            }
            DispatchQueue.main.async {
                self.healthData = HealthData(stepCount: sum.doubleValue(for: HKUnit.count()))
            }
        }
        healthStore.execute(query)
    }
}

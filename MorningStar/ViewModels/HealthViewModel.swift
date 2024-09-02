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
    
    @Published var healthData = HealthData()
    @Published var authorizationStatus: Bool = false // Create enum
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            .quantityType(forIdentifier: .stepCount)!,
            .quantityType(forIdentifier: .bodyMass)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    self?.authorizationStatus = success
                    self?.fetchAllHealthData()
                }
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    public func fetchAllHealthData() {
        fetchWeightHistory()
        fetchStepCountHistory()
        fetchCaloriesBurnedHistory()
        fetchSleepHistory()
    }
    
    private func fetchWeightHistory() {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            print("Body mass type is not available")
            return
        }
        let query = createSampleQuery(for: weightType) { samples in
            let weights = samples.compactMap { sample -> HealthData.WeightEntry? in
                guard let quantitySample = sample as? HKQuantitySample else {
                    return nil
                }
                return HealthData.WeightEntry(
                    date: quantitySample.startDate,
                    value: quantitySample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                )
            }
            DispatchQueue.main.async {
                self.healthData.weightHistory = weights
            }
        }
        healthStore.execute(query)
    }
    
    private func fetchStepCountHistory() {
        fetchActivityHistory(for: .stepCount, unit: .count()) { entries in
            self.healthData.stepCountHistory = entries
        }
    }
    
    private func fetchCaloriesBurnedHistory() {
        fetchActivityHistory(for: .activeEnergyBurned, unit: .kilocalorie()) { entries in
            self.healthData.calorieBurnHistory = entries
        }
    }
    
    private func fetchActivityHistory(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, completion: @escaping ([HealthData.DailyActivityEntry]) -> Void) {
        guard let activityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            print("Invalid activity type identifier")
            return
        }
        let query = createStatisticsCollectionQuery(for: activityType, unit: unit) { statisticsCollection in
            var entries: [HealthData.DailyActivityEntry] = []
            statisticsCollection.enumerateStatistics(from: Date.distantPast, to: Date()) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let entry = HealthData.DailyActivityEntry(
                        date: statistics.startDate,
                        values: [sum.doubleValue(for: unit)]
                    )
                    entries.append(entry)
                }
            }
            DispatchQueue.main.async {
                completion(entries)
            }
        }
        healthStore.execute(query)
    }

    private func fetchSleepHistory() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep analysis type is not available")
            return
        }
        let query = createSampleQuery(for: sleepType) { samples in
            let sleepEntries = Dictionary(grouping: samples.compactMap { sample -> (Date, HealthData.SleepEntry)? in
                guard let categorySample = sample as? HKCategorySample,
                      let sleepQuality = HKCategoryValueSleepAnalysis(rawValue: categorySample.value) else {
                    return nil
                }
                let entry = HealthData.SleepEntry(
                    start: categorySample.startDate,
                    end: categorySample.endDate,
                    duration: categorySample.endDate.timeIntervalSince(categorySample.startDate),
                    quality: sleepQuality
                )
                return (Calendar.current.startOfDay(for: categorySample.startDate), entry)
            }) { $0.0 }.mapValues { $0.map { $0.1 } }
            
            DispatchQueue.main.async {
                self.healthData.sleepHistory = sleepEntries
            }
        }
        healthStore.execute(query)
    }

    private func createStatisticsCollectionQuery(for quantityType: HKQuantityType, unit: HKUnit, resultHandler: @escaping (HKStatisticsCollection) -> Void) -> HKStatisticsCollectionQuery {
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        let dailyInterval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: dailyInterval)
        
        query.initialResultsHandler = { _, results, error in
            guard let results = results, error == nil else {
                print("Error fetching statistics: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            resultHandler(results)
        }
        
        return query
    }

    private func createSampleQuery(for sampleType: HKSampleType, resultHandler: @escaping ([HKSample]) -> Void) -> HKSampleQuery {
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date(), options: .strictEndDate)
        return HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples, error == nil else {
                print("Error fetching samples: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            resultHandler(samples)
        }
    }
}

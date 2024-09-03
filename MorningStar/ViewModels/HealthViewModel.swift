//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import Foundation
import HealthKit

enum AuthorizationStatus {
    case notDetermined
    case authorized
    case denied
}

class HealthViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    
    @Published var healthData = HealthData()
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            .quantityType(forIdentifier: .stepCount)!,
            .quantityType(forIdentifier: .bodyMass)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .categoryType(forIdentifier: .sleepAnalysis)!,
            .workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.authorizationStatus = .authorized
                    self?.fetchAllHealthData()
                } else {
                    self?.authorizationStatus = .denied
                    print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    public func fetchAllHealthData() {
        fetchWeightHistory()
        fetchStepCountHistory()
        fetchCaloriesBurnedHistory()
        fetchSleepHistory()
        fetchWorkoutHistory()
    }
    
    private func fetchWeightHistory() {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            print("Body mass type is not available")
            return
        }
        let query = createSampleQuery(for: weightType) { samples in
            let weights = samples.compactMap { sample -> HealthData.WeightEntry? in
                guard let quantitySample = sample as? HKQuantitySample else { return nil }
                return HealthData.WeightEntry(
                    date: quantitySample.startDate,
                    value: quantitySample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                )
            }
            DispatchQueue.main.async {
                self.healthData.weightHistory = weights
            }
        }
        healthStore.execute(query)
    }
    
    private func fetchStepCountHistory() {
        fetchHourlyActivityHistory(for: .stepCount, unit: .count()) { entries in
            self.healthData.stepCountHistory = entries
        }
    }
    
    private func fetchCaloriesBurnedHistory() {
        fetchHourlyActivityHistory(for: .activeEnergyBurned, unit: .kilocalorie()) { entries in
            self.healthData.calorieBurnHistory = entries
        }
    }
    
    private func fetchWorkoutHistory() {
        fetchHourlyActivityHistory(for: .distanceWalkingRunning, unit: .meter()) { entries in
            self.healthData.workoutHistory = entries
        }
    }

    private func fetchHourlyActivityHistory(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, completion: @escaping ([(date: Date, activity: [HealthData.HourlyActivityEntry])]) -> Void) {
        guard let activityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            print("Invalid activity type identifier")
            return
        }

        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .year, value: -10, to: Date()) ?? Date.distantPast
        let anchorDate = calendar.startOfDay(for: startDate)

        let hourlyInterval = DateComponents(hour: 1)

        let query = HKStatisticsCollectionQuery(
            quantityType: activityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: hourlyInterval
        )

        query.initialResultsHandler = { _, results, error in
            guard let results = results, error == nil else {
                print("Error fetching hourly activity data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var activityEntries: [(date: Date, activity: [HealthData.HourlyActivityEntry])] = []

            results.enumerateStatistics(from: startDate, to: Date()) { statistics, _ in
                let startDate = statistics.startDate
                let endDate = statistics.endDate
                let value = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0.0

                let entry = HealthData.HourlyActivityEntry(start: startDate, end: endDate, value: value)

                let day = calendar.startOfDay(for: startDate)
                
                if let index = activityEntries.firstIndex(where: { $0.date == day }) {
                    activityEntries[index].activity.append(entry)
                } else {
                    activityEntries.append((date: day, activity: [entry]))
                }
            }

            DispatchQueue.main.async {
                completion(activityEntries)
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

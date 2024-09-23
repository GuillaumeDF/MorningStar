//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import Foundation
import HealthKit

enum AuthorizationStatus {
    case notDetermined, authorized, denied
}

class HealthViewModel: ObservableObject {
    @Published var healthData = HealthData()
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    
    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current
    
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
                self?.authorizationStatus = success ? .authorized : .denied
                if success {
                    self?.fetchAllHealthData()
                } else {
                    print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func fetchAllHealthData() {
        fetchWeightHistory()
        fetchStepCountHistory()
        fetchCaloriesBurnedHistory()
        fetchSleepQualityHistory()
        fetchWorkoutHistory()
    }
    
    private func fetchWeightHistory() {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            print("Body mass type is not available")
            return
        }
        
        let query = createSampleQuery(for: weightType) { [weak self] samples in
            let weightEntries = samples.compactMap { sample -> HealthData.WeightEntry? in
                guard let quantitySample = sample as? HKQuantitySample else { return nil }
                
                return HealthData.WeightEntry(
                    date: quantitySample.startDate,
                    weight: Measurement(
                        value: quantitySample.quantity.doubleValue(for: .gramUnit(with: .kilo)),
                        unit: .kilocalorie()
                    )
                )
            }
            
            let dailyActivity = DailyActivity(activities: weightEntries)
            
            DispatchQueue.main.async {
                self?.healthData.weightHistory = [dailyActivity]
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchStepCountHistory() {
        fetchHourlyActivityHistory(for: .stepCount, unit: .count()) { [weak self] entries in
            self?.healthData.stepCountHistory = entries
        }
    }
    
    private func fetchCaloriesBurnedHistory() {
        fetchHourlyActivityHistory(for: .activeEnergyBurned, unit: .kilocalorie()) { [weak self] entries in
            self?.healthData.calorieBurnHistory = entries
        }
    }
    
    private func fetchSleepQualityHistory() {
        fetchHourlySleepQuality { [weak self] entries in
            self?.healthData.sleepHistory = entries
        }
    }
    
    private func fetchWorkoutHistory() {
        // Implement workout history fetching
    }
    
    private func fetchHourlyActivityHistory(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, completion: @escaping ([DailyActivity<HealthData.ActivityEntry>]) -> Void) {
        guard let activityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            print("Invalid activity type identifier")
            return
        }
        
        let endDate = Date()
        let startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
        let anchorDate = calendar.startOfDay(for: startDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: activityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: DateComponents(hour: 1)
        )
        
        query.initialResultsHandler = { [weak self] _, results, error in
            guard let self = self, let statsCollection = results, error == nil else {
                print("Error fetching hourly activity data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let dailyActivities = self.processDailyActivities(statsCollection: statsCollection, startDate: startDate, endDate: endDate, unit: unit)
            
            DispatchQueue.main.async {
                completion(dailyActivities)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func processDailyActivities(statsCollection: HKStatisticsCollection, startDate: Date, endDate: Date, unit: HKUnit) -> [DailyActivity<HealthData.ActivityEntry>] {
        var dailyActivities: [DailyActivity<HealthData.ActivityEntry>] = []
        var currentDayActivities: [HealthData.ActivityEntry] = []
        var currentDay: Date?
        
        statsCollection.enumerateStatistics(from: startDate, to: endDate) { [weak self] statistics, _ in
            guard let self = self else { return }
            
            let day = self.calendar.startOfDay(for: statistics.startDate)
            
            if currentDay != day {
                if !currentDayActivities.isEmpty {
                    dailyActivities.append(DailyActivity(activities: currentDayActivities))
                }
                currentDay = day
                currentDayActivities = []
            }
            
            let entry = HealthData.ActivityEntry(
                start: statistics.startDate,
                end: statistics.endDate,
                measurement: Measurement(
                    value: statistics.sumQuantity()?.doubleValue(for: unit) ?? 0.0,
                    unit: unit
                )
            )
            currentDayActivities.append(entry)
        }
        
        if !currentDayActivities.isEmpty {
            dailyActivities.append(DailyActivity(activities: currentDayActivities))
        }
        
        return dailyActivities
    }
    
    private func fetchHourlySleepQuality(completion: @escaping ([DailyActivity<HealthData.SleepEntry>]) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep analysis type is not available")
            return
        }
        
        let endDate = Date()
        let startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { [weak self] _, samples, error in
            guard let self = self, let samples = samples as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let dailyActivities = self.processSleepEntries(samples: samples)
            
            DispatchQueue.main.async {
                completion(dailyActivities)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func processSleepEntries(samples: [HKCategorySample]) -> [DailyActivity<HealthData.SleepEntry>] {
        var dailyActivities: [DailyActivity<HealthData.SleepEntry>] = []
        var currentDayEntries: [HealthData.SleepEntry] = []
        var currentDay: Date?
        
        for sample in samples {
            let sampleStartDate = sample.startDate
            let day = calendar.startOfDay(for: sampleStartDate)
            
            if currentDay != day {
                if !currentDayEntries.isEmpty {
                    dailyActivities.append(DailyActivity(activities: currentDayEntries))
                }
                currentDay = day
                currentDayEntries = []
            }
            
            let hourlyEntries = processHourlySleepEntries(for: sample)
            currentDayEntries.append(contentsOf: hourlyEntries)
        }
        
        if !currentDayEntries.isEmpty {
            dailyActivities.append(DailyActivity(activities: currentDayEntries))
        }
        
        return dailyActivities
    }
    
    private func processHourlySleepEntries(for sample: HKCategorySample) -> [HealthData.SleepEntry] {
        var entries: [HealthData.SleepEntry] = []
        var currentHourStart = sample.startDate
        
        while currentHourStart < sample.endDate {
            let nextHourStart = calendar.date(byAdding: .hour, value: 1, to: currentHourStart)!
            let intervalEnd = min(nextHourStart, sample.endDate)
            
            let sleepQuality = HKCategoryValueSleepAnalysis(rawValue: sample.value) ?? .asleepUnspecified
            
            let entry = HealthData.SleepEntry(
                start: currentHourStart,
                end: intervalEnd,
                duration: intervalEnd.timeIntervalSince(currentHourStart),
                quality: sleepQuality
            )
            entries.append(entry)
            
            currentHourStart = nextHourStart
        }
        
        return entries
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

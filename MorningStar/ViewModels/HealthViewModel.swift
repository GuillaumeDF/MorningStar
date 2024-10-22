//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import HealthKit

enum AuthorizationStatus {
    case notDetermined, authorized, denied
}

class HealthViewModel: ObservableObject {
    @Published var healthData = HealthData()
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
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
            .quantityType(forIdentifier: .heartRate)!,
            .categoryType(forIdentifier: .sleepAnalysis)!,
            .workoutType(),
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.authorizationStatus = success ? .authorized : .denied
                if success {
                    self?.fetchAllHealthData()
                } else {
                    self?.errorMessage = "Authorization failed: \(error?.localizedDescription ?? "Unknown error")"
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
    
    private func fetchStepCountHistory() {
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        
        StepDataManagerFactory.createStatisticsManager(healthStore: healthStore, from: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.stepCountHistory = entries
                    self?.healthData.totalStepThisWeek = self?.calculateTotalStepThisWeek(periodsEntry: entries) ?? 0
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchCaloriesBurnedHistory() {
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        
        CalorieBurnedDataManagerFactory.createStatisticsManager(healthStore: healthStore, from: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.calorieBurnHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchWeightHistory() {
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        
        WeightDataManagerFactory.createSampleManager(healthStore: healthStore, from: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.weightHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchSleepQualityHistory() {
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        
        SleepDataManagerFactory.createSampleManager(healthStore: healthStore, from: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.sleepHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchWorkoutHistory() {
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        
        WorkoutDataManagerFactory.createSampleManager(healthStore: healthStore, from: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.workoutHistory = entries
                    self?.healthData.totalWorkoutHoursThisWeek = self?.calculateTotalWorkoutHoursThisWeek(weeklyWorkoutSessions: entries.first) ?? (0, 0)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func calculateTotalWorkoutHoursThisWeek(weeklyWorkoutSessions: HealthData.WeeklyWorkoutSessions?) -> (hours: Int, minutes: Int) {
        let calendar = Calendar.current
        let now = Date()
        
        guard let workoutSessions = weeklyWorkoutSessions,
              let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return (0, 0)
        }
        
        let totalDurationInSeconds = workoutSessions.flatMap { $0 }
            .flatMap { $0 }
            .reduce(0.0) { total, workoutEntry in
                if workoutEntry.startDate >= weekStart && workoutEntry.endDate <= weekEnd {
                    return total + workoutEntry.duration
                }
                return total
            }
        
        let hours = Int(totalDurationInSeconds / 3600)
        let minutes = Int((totalDurationInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        return (hours, minutes)
    }
    
    private func calculateTotalStepThisWeek(periodsEntry: [PeriodEntry<HealthData.ActivityEntry>]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        guard !periodsEntry.isEmpty,
              let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return 0
        }
        
        var total: Double = 0.0
        
        for periodEntry in periodsEntry {
            for entry in periodEntry.entries {
                if entry.startDate >= weekStart && entry.endDate <= weekEnd {
                    total += entry.value
                } else if entry.startDate < weekStart {
                    break
                }
            }
        }
        
        return Int(total)
    }
}

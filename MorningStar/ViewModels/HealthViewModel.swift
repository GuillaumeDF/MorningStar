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
        let startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
        
        WorkoutDataManagerFactory.createSampleManager(healthStore: healthStore, from: startDate).fetchData {  [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.healthData.workoutHistory = entries
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

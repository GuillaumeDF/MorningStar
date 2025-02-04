//
//  HealthMetrics.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

struct HealthMetrics {
    var stepCountHistory: [StepPeriod] = []
    var calorieBurnedHistory: [CaloriesPeriod] = []
    var weightHistory: [WeightPeriod] = []
    var sleepHistory: [SleepPeriod] = []
    var workoutHistory: [WeeklyWorkouts] = []
    
    mutating func set<T>(_ type: HealthDataType, items: [T]) {
        switch type {
        case .steps:
            stepCountHistory = items as? [StepPeriod] ?? []
        case .calories:
            calorieBurnedHistory = items as? [CaloriesPeriod] ?? []
        case .weight:
            weightHistory = items as? [WeightPeriod] ?? []
        case .sleep:
            sleepHistory = items as? [SleepPeriod] ?? []
        case .workouts:
            workoutHistory = items as? [WeeklyWorkouts] ?? []
        }
    }
}

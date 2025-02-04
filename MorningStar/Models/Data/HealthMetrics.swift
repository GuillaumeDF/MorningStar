//
//  HealthMetrics.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

enum HealthMetricType: CaseIterable, CustomStringConvertible {
    case steps
    case calories
    case weight
    case sleep
    case workouts
    //case heartRate
    
    var description: String {
        switch self {
        case .steps: return "steps"
        case .calories: return "calories"
        case .weight: return "weight"
        case .sleep: return "sleep"
        case .workouts: return "workouts"
            //case .heartRate: return "heartRate"
        }
    }
    
    var healthKitFactory: any HealthDataFactoryProtocol.Type {
        switch self {
        case .steps: return StepDataManagerFactory.self
        case .calories: return CalorieBurnedDataManagerFactory.self
        case .weight: return WeightDataManagerFactory.self
        case .sleep: return SleepDataManagerFactory.self
        case .workouts: return WorkoutDataManagerFactory.self
            //case .heartRate: return HeartRateDataManagerFactory.self // TODO: A vérifier
        }
    }
}

struct HealthMetrics {
    var stepCountHistory: [StepPeriod] = []
    var calorieBurnedHistory: [CaloriesPeriod] = []
    var weightHistory: [WeightPeriod] = []
    var sleepHistory: [SleepPeriod] = []
    var workoutHistory: [WeeklyWorkouts] = []
    
    mutating func set<T>(_ type: HealthMetricType, items: [T]) {
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

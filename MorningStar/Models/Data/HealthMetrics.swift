//
//  HealthMetrics.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import SwiftUICore

enum HealthMetricType: CaseIterable, CustomStringConvertible {
    case steps
    case calories
    case weight
    case sleep
    case workouts
    
    var description: String {
        switch self {
        case .steps: return "steps"
        case .calories: return "calories"
        case .weight: return "weight"
        case .sleep: return "sleep"
        case .workouts: return "workouts"
        }
    }
    
    var color: Color {
        switch self {
        case .steps: return Color.stepColor
        case .calories: return Color.calorieColor
        case .weight: return Color.weightColor
        case .sleep: return Color.blue
        case .workouts: return Color.trainingColor
        }
    }
    
    var debugSymbol: String {
        switch self {
        case .steps: return "👣"
        case .calories: return "🔥"
        case .weight: return "⚖️"
        case .sleep: return "💤"
        case .workouts: return "🏋️"
        }
    }
    
    var healthKitFactory: any HealthDataFactoryProtocol.Type {
        switch self {
        case .steps: return StepDataManagerFactory.self
        case .calories: return CalorieBurnedDataManagerFactory.self
        case .weight: return WeightDataManagerFactory.self
        case .sleep: return SleepDataManagerFactory.self
        case .workouts: return WorkoutDataManagerFactory.self
        }
    }
}

struct HealthMetrics {
    var stepCountHistory: [StepPeriod] = []
    var calorieBurnedHistory: [CaloriesPeriod] = []
    var weightHistory: [WeightPeriod] = []
    var sleepHistory: [SleepPeriod] = []
    var workoutHistory: [WeeklyWorkouts] = []
    
    // TODO: A revoir la logique ne devrait pas se trouver ici
    var totalWorkoutHoursThisWeek: String {
        let totalSeconds = workoutHistory.first?.dailyWorkouts.reduce(into: 0) { result, dailyWorkout in
            dailyWorkout.workouts.forEach { workout in
                workout.phaseEntries.forEach { phase in
                    result += phase.duration
                }
            }
        } ?? 0
        
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        
        return "\(hours)h \(minutes)m"
    }
    
    var totalStepThisWeek: Int = 0
    
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

//
//  HealthData.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import Foundation
import HealthKit

protocol HealthEntry: Identifiable {
    associatedtype T
    
    var startDate: Date { get }
    var endDate: Date { get }
    var value: T { get }
    var unit: String { get }
}

enum IntensityLevel {
    case undetermined
    case low
    case moderate
    case high
    case veryHigh
}

struct PeriodEntry<T: HealthEntry>: Identifiable {
    let id = UUID()
    var entries: [T]
}

struct HealthData {
    typealias WorkoutPhaseEntries = [WorkoutEntry]
    typealias DailyWorkoutSessions = [WorkoutPhaseEntries]
    typealias WeeklyWorkoutSessions = [DailyWorkoutSessions]
    typealias WorkoutHistory = [WeeklyWorkoutSessions]
    
    struct WeightEntry: HealthEntry {
        typealias T = Double
        
        let id = UUID()
        let startDate: Date
        let endDate: Date
        let value: T
        let unit: String
    }
    
    struct ActivityEntry: HealthEntry {
        typealias T = Double
        
        let id = UUID()
        let startDate: Date
        let endDate: Date
        let value: T
        let unit: String
    }
    
    struct SleepEntry: HealthEntry {
        typealias T = TimeInterval
        
        let id = UUID()
        let startDate: Date
        let endDate: Date
        let unit: String
        
        var value: T {
            return endDate.timeIntervalSince(startDate)
        }
    }
    
    struct WorkoutEntry: HealthEntry {
        typealias T = IntensityLevel
        
        let id = UUID()
        let startDate: Date
        var endDate: Date
        let value: T
        let unit: String = ""
        let averageHeartRate: Double
        let caloriesBurned: Double
    }
    
    struct HeartRateEntry: HealthEntry {
        typealias T = Double
        
        let id = UUID()
        let startDate: Date
        let endDate: Date
        let value: T
        let unit: String = ""
    }
    
    var weightHistory: [PeriodEntry<WeightEntry>]
    var stepCountHistory: [PeriodEntry<ActivityEntry>]
    var calorieBurnHistory: [PeriodEntry<ActivityEntry>]
    var sleepHistory: [PeriodEntry<SleepEntry>]
    var workoutHistory: WorkoutHistory
    
    init() {
        self.weightHistory = []
        self.stepCountHistory = []
        self.calorieBurnHistory = []
        self.sleepHistory = []
        self.workoutHistory = []
    }
}

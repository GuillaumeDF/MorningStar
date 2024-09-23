//
//  HealthData.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import Foundation
import HealthKit

protocol HealthEntry: Identifiable {
    var start: Date { get }
    var end: Date? { get }
    var value: Double { get }
    var unit: HKUnit? { get }
}

struct Measurement<T: Numeric & Comparable> {
    let value: T
    let unit: HKUnit
}

struct DailyActivity<T: HealthEntry>: Identifiable {
    let id = UUID()
    var activities: [T]
    
    var date: Date? {
        activities.first?.start
    }
    
    var total: Double {
        activities.compactMap { $0.value }.reduce(0, +)
    }
}

struct HealthData {
    struct WeightEntry: HealthEntry {
        let id = UUID()
        let date: Date
        let weight: Measurement<Double>
        
        var start: Date { date }
        var end: Date? { nil }
        var value: Double { weight.value }
        var unit: HKUnit? { weight.unit }
    }
    
    struct ActivityEntry: HealthEntry {
        let id = UUID()
        let start: Date
        let end: Date?
        let measurement: Measurement<Double>
        
        var value: Double { measurement.value }
        var unit: HKUnit? { measurement.unit }
    }
    
    struct SleepEntry: HealthEntry {
        let id = UUID()
        let start: Date
        let end: Date?
        let duration: TimeInterval
        let quality: HKCategoryValueSleepAnalysis
        
        var value: Double { duration }
        var unit: HKUnit? { .hour() }
    }
    
    struct WorkoutEntry: HealthEntry {
        let id = UUID()
        let start: Date
        let end: Date?
        let duration: TimeInterval
        let energyBurned: Measurement<Double>?
        let distance: Measurement<Double>?
        let workoutActivityType: HKWorkoutActivityType
        
        var value: Double { energyBurned?.value ?? 0 }
        var unit: HKUnit? { energyBurned?.unit }
    }
    
    var weightHistory: [DailyActivity<WeightEntry>]
    var stepCountHistory: [DailyActivity<ActivityEntry>]
    var calorieBurnHistory: [DailyActivity<ActivityEntry>]
    var sleepHistory: [DailyActivity<SleepEntry>]
    var workoutHistory: [DailyActivity<WorkoutEntry>]
    
    init() {
        self.weightHistory = []
        self.stepCountHistory = []
        self.calorieBurnHistory = []
        self.sleepHistory = []
        self.workoutHistory = []
    }
}

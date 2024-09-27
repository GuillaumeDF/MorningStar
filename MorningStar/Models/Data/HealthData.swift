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
    var unit: String { get }
}

struct Measurement<T: Numeric & Comparable> {
    let value: T
    let unit: String
}

struct PeriodActivity<T: HealthEntry>: Identifiable {
    let id = UUID()
    var activities: [T]
}

struct HealthData {
    struct WeightEntry: HealthEntry {
        let id = UUID()
        let date: Date
        let weight: Measurement<Double>
        
        var start: Date { date }
        var end: Date? { nil }
        var value: Double { weight.value }
        var unit: String { weight.unit }
    }
    
    struct ActivityEntry: HealthEntry {
        let id = UUID()
        let start: Date
        let end: Date?
        let measurement: Measurement<Double>
        
        var value: Double { measurement.value }
        var unit: String { measurement.unit }
    }
    
    struct SleepEntry: HealthEntry {
        let id = UUID()
        let start: Date
        let end: Date?
        let duration: TimeInterval
        let quality: HKCategoryValueSleepAnalysis
        
        var value: Double { duration }
        var unit: String { HKUnit.hour().unitString }
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
        var unit: String { energyBurned?.unit ?? "none" }
    }
    
    var weightHistory: [PeriodActivity<WeightEntry>]
    var stepCountHistory: [PeriodActivity<ActivityEntry>]
    var calorieBurnHistory: [PeriodActivity<ActivityEntry>]
    var sleepHistory: [PeriodActivity<SleepEntry>]
    var workoutHistory: [PeriodActivity<WorkoutEntry>]
    
    init() {
        self.weightHistory = []
        self.stepCountHistory = []
        self.calorieBurnHistory = []
        self.sleepHistory = []
        self.workoutHistory = []
    }
}

//
//  HealthData.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import Foundation
import HealthKit
import SwiftUI

typealias WeightPeriod = PeriodEntry<HealthData.WeightEntry>
typealias CaloriesPeriod = PeriodEntry<HealthData.ActivityEntry>
typealias StepPeriod = PeriodEntry<HealthData.ActivityEntry>
typealias SleepPeriod = PeriodEntry<HealthData.SleepEntry>
typealias HeartRatePeriod = PeriodEntry<HealthData.HeartRateEntry>

typealias WeeklyWorkouts = HealthData.WeeklyWorkouts
typealias DailyWorkouts = HealthData.DailyWorkouts
typealias Workout = HealthData.Workout

enum IntensityLevel: UInt8, Hashable {
    case undetermined = 0
    case low = 1
    case moderate = 2
    case high = 3
    case veryHigh = 4
    
    var color: Color {
        switch self {
        case .undetermined: return Color.undeterminedIntensityColor
        case .low: return Color.lowIntensityColor
        case .moderate: return Color.moderateIntensityColor
        case .high: return Color.highIntensityColor
        case .veryHigh: return Color.veryHighIntensityColor
        }
    }
}

protocol HealthEntry: Identifiable, Hashable {
    associatedtype T
    
    var startDate: Date { get }
    var endDate: Date { get }
    var value: T { get }
    var unit: String { get }
}

struct PeriodEntry<T: HealthEntry>: Identifiable, Equatable {
    let id: UUID
    var entries: [T]
    
    var startDate: Date? {
        entries.first?.startDate
    }
    
    var endDate: Date? {
        entries.last?.endDate
    }
    
    init(id: UUID? = nil, entries: [T]) {
        self.id = id ?? UUID()
        self.entries = entries
    }
}

struct HealthData { }

extension HealthData {
    struct WeightEntry: HealthEntry {
        typealias T = Double
        
        let id: UUID
        let startDate: Date
        let endDate: Date
        let value: T
        let unit: String
        
        init(id: UUID? = nil, startDate: Date, endDate: Date, value: T, unit: String) {
            self.id = id ?? UUID()
            self.startDate = startDate
            self.endDate = endDate
            self.value = value
            self.unit = unit
        }
    }
}

extension HealthData {
    struct ActivityEntry: HealthEntry {
        typealias T = Double

        let id: UUID
        let startDate: Date
        let endDate: Date
        let value: T
        let unit: String

        init(id: UUID? = nil, startDate: Date, endDate: Date, value: T, unit: String) {
            self.id = id ?? UUID()
            self.startDate = startDate
            self.endDate = endDate
            self.value = value
            self.unit = unit
        }
    }
}

extension HealthData {
    struct SleepEntry: HealthEntry {
        typealias T = TimeInterval
        
        let id: UUID
        let startDate: Date
        let endDate: Date
        let unit: String
        
        var value: T {
            return endDate.timeIntervalSince(startDate)
        }
        
        init(id: UUID? = nil, startDate: Date, endDate: Date, unit: String = "") {
            self.id = id ?? UUID()
            self.startDate = startDate
            self.endDate = endDate
            self.unit = unit
        }
    }
}

extension HealthData {
    struct HeartRateEntry: HealthEntry {
        typealias T = Double
        
        let id: UUID
        let startDate: Date
        let endDate: Date
        let value: T
        let unit: String
        
        init(id: UUID? = nil, startDate: Date, endDate: Date, value: T, unit: String = "") {
            self.id = id ?? UUID()
            self.startDate = startDate
            self.endDate = endDate
            self.value = value
            self.unit = unit
        }
    }
}

extension HealthData {
    struct WeeklyWorkouts: Hashable {
        let id: UUID
        var dailyWorkouts: [DailyWorkouts]
        
        var startDate: Date? {
            dailyWorkouts.first?.startDate
        }
        
        var endDate: Date? {
            dailyWorkouts.last?.endDate
        }
        
        init(id: UUID? = nil, dailyWorkouts: [DailyWorkouts]) {
            self.id = id ?? UUID()
            self.dailyWorkouts = dailyWorkouts
        }
    }
    
    struct DailyWorkouts: Hashable {
        let id: UUID
        var workouts: [Workout]
        
        var startDate: Date? {
            workouts.first?.startDate
        }
        
        var endDate: Date? {
            workouts.last?.endDate
        }
        
        init(id: UUID? = nil, workouts: [Workout]) {
            self.id = id ?? UUID()
            self.workouts = workouts
        }
    }
    
    struct Workout: Hashable {
        let id: UUID
        let type: UInt16
        var phaseEntries: [WorkoutPhaseEntry]
        
        var startDate: Date? {
            phaseEntries.first?.startDate
        }
        
        var endDate: Date? {
            phaseEntries.last?.endDate
        }
        
        init(id: UUID? = nil, type: UInt16, phaseEntries: [WorkoutPhaseEntry]) {
            self.id = id ?? UUID()
            self.type = type
            self.phaseEntries = phaseEntries
        }
    }
    
    struct WorkoutPhaseEntry: HealthEntry {
        typealias T = IntensityLevel
        
        let id: UUID
        let startDate: Date
        var endDate: Date
        let value: T
        let unit: String
        let averageHeartRate: Double
        let caloriesBurned: Double
        
        var duration: Double {
            return endDate.timeIntervalSince(startDate)
        }
        
        init(id: UUID? = nil,
             startDate: Date,
             endDate: Date,
             value: T,
             unit: String = "",
             averageHeartRate: Double,
             caloriesBurned: Double) {
            self.id = id ?? UUID()
            self.startDate = startDate
            self.endDate = endDate
            self.value = value
            self.unit = unit
            self.averageHeartRate = averageHeartRate
            self.caloriesBurned = caloriesBurned
        }
    }
}


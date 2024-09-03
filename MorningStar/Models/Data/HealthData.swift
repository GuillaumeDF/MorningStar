//
//  HealthData.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import SwiftUI
import HealthKit

/*
 MSLineChartCardView(
     imageName: "weightIcon",
     title: "Weight",
     valeur: "75",
     unity: "kg",
     arrowDirection: .up,
     backgroundColor: Color.weightColor
 )
 */

protocol HealthDataItem: Identifiable {
    var id: UUID { get }
    var date: Date { get }
    var title: String { get }
    var unity: String { get }
    var arrowDirection: ArrowDirection { get }
    var color: Color { get }
}

struct HealthData {
    struct WeightEntry: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }
    
    struct HourlyActivityEntry: Identifiable {
        let id = UUID()
        let start: Date
        let end: Date
        let value: Double
    }
    
    struct SleepEntry: Identifiable {
        let id = UUID()
        let start: Date
        let end: Date
        let duration: TimeInterval
        let quality: HKCategoryValueSleepAnalysis
    }
    
    struct WorkoutEntry: Identifiable {
        let id = UUID()
        let startDate: Date
        let endDate: Date
        let duration: TimeInterval
        let energyBurned: Double?
        let distance: Double?
        let workoutActivityType: HKWorkoutActivityType
    }
    
    var weightHistory: [WeightEntry] = []
    var stepCountHistory: [(date: Date, activity: [HourlyActivityEntry])] = [(Date(), [])]
    var calorieBurnHistory: [(date: Date, activity: [HourlyActivityEntry])] = [(Date(), [])]
    var sleepHistory: [Date: [SleepEntry]] = [:]
    var workoutHistory: [(date: Date, activity: [HourlyActivityEntry])] = [(Date(), [])]
}

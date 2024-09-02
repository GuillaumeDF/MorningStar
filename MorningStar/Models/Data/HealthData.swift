//
//  HealthData.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import HealthKit

struct HealthData {
    struct WeightEntry: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }
    
    struct DailyActivityEntry: Identifiable {
        let id = UUID()
        let date: Date
        let values: [Double]
    }
    
    struct SleepEntry: Identifiable {
        let id = UUID()
        let start: Date
        let end: Date
        let duration: TimeInterval
        let quality: HKCategoryValueSleepAnalysis
    }
    
    var weightHistory: [WeightEntry] = []
    var stepCountHistory: [DailyActivityEntry] = []
    var calorieBurnHistory: [DailyActivityEntry] = []
    var sleepHistory: [Date: [SleepEntry]] = [:]
}

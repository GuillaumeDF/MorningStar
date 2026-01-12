//
//  HealthTypes+UI.swift
//  MorningStar
//
//  UI extensions for health data types - separated for testability
//

import SwiftUI

// MARK: - IntensityLevel UI Extension

extension IntensityLevel {
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

// MARK: - HealthMetricType UI Extension

extension HealthMetricType {
    var color: Color {
        switch self {
        case .steps: return Color.stepColor
        case .calories: return Color.calorieColor
        case .weight: return Color.weightColor
        case .sleep: return Color.blue
        case .workouts: return Color.trainingColor
        }
    }
}

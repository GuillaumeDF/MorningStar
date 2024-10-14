//
//  WorkoutIntensityAnalyzer.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/10/2024.
//

import Foundation
import HealthKit

class WorkoutIntensityAnalyzer {
    
    private enum Constants {
        static let minPhaseDurationFactor: Double = 0.05
        static let minPhaseDurationSeconds: TimeInterval = 30
        static let variabilityThresholdFactor: Double = 0.7
        static let lowIntensityThreshold: Double = 0.8
        static let moderateIntensityThreshold: Double = 1.1
        static let highIntensityThreshold: Double = 1.4
    }
    
    func generateIntensityPhases(
        workout: HKSample,
        heartRates: [HealthData.HeartRateEntry],
        caloriesBurned: [HealthData.ActivityEntry]
    ) -> [HealthData.WorkoutEntry] {
        guard !heartRates.isEmpty else {
            return [createUndeterminedPhase(startDate: workout.startDate, endDate: workout.endDate)]
        }
        
        let duration = workout.endDate.timeIntervalSince(workout.startDate)
        let globalAverages = calculateGlobalAverages(heartRates: heartRates, caloriesBurned: caloriesBurned, duration: duration)
        let thresholds = calculateThresholds(heartRates: heartRates, caloriesBurned: caloriesBurned, globalAverages: globalAverages)
        let minPhaseDuration = max(duration * Constants.minPhaseDurationFactor, Constants.minPhaseDurationSeconds)
        
        return generatePhases(
            workout: workout,
            heartRates: heartRates,
            caloriesBurned: caloriesBurned,
            globalAverages: globalAverages,
            thresholds: thresholds,
            minPhaseDuration: minPhaseDuration
        )
    }
    
    private func createUndeterminedPhase(startDate: Date, endDate: Date) -> HealthData.WorkoutEntry {
        return HealthData.WorkoutEntry(startDate: startDate, endDate: endDate, value: .undetermined, averageHeartRate: 0, caloriesBurned: 0)
    }
    
    private func calculateGlobalAverages(heartRates: [HealthData.HeartRateEntry], caloriesBurned: [HealthData.ActivityEntry], duration: TimeInterval) -> (heartRate: Double, calorieRate: Double) {
        let avgHeartRate = calculateAverageHeartRate(heartRates)
        let avgCalorieRate = calculateCaloriesBurnedRate(caloriesBurned, duration: duration)
        
        return (heartRate: avgHeartRate, calorieRate: avgCalorieRate)
    }
    
    private func calculateHeartRateVariability(_ entries: [HealthData.HeartRateEntry], globalAverage: Double) -> Double {
        let variance = entries.reduce(0.0) { sum, entrie in
            let heartRate = entrie.value
            let difference = heartRate - globalAverage
            
            return sum + (difference * difference)
        }
        return sqrt(variance / Double(entries.count))
    }
    
    private func calculateCaloriesVariability(_ entries: [HealthData.ActivityEntry], globalAverage: Double) -> Double {
        let variance = entries.reduce(0.0) { sum, entry in
            let calories = entry.value
            let difference = calories - globalAverage
            
            return sum + (difference * difference)
        }
        return sqrt(variance / Double(entries.count))
    }
    
    private func calculateThresholds(heartRates: [HealthData.HeartRateEntry], caloriesBurned: [HealthData.ActivityEntry], globalAverages: (heartRate: Double, calorieRate: Double)) -> (heartRate: Double, calorieRate: Double) {
        let heartRateVariability = calculateHeartRateVariability(heartRates, globalAverage: globalAverages.heartRate)
        let calorieRateVariability = calculateCaloriesVariability(caloriesBurned, globalAverage: globalAverages.calorieRate)
        
        return (
            heartRate: heartRateVariability * Constants.variabilityThresholdFactor,
            calorieRate: calorieRateVariability * Constants.variabilityThresholdFactor
        )
    }
    
    private func generatePhases(
        workout: HKSample,
        heartRates: [HealthData.HeartRateEntry],
        caloriesBurned: [HealthData.ActivityEntry],
        globalAverages: (heartRate: Double, calorieRate: Double),
        thresholds: (heartRate: Double, calorieRate: Double),
        minPhaseDuration: TimeInterval
    ) -> [HealthData.WorkoutEntry] {
        var phases: [HealthData.WorkoutEntry] = []
        var currentPhaseStart = workout.startDate
        var previousStats: (heartRate: Double?, calorieRate: Double?) = (
            heartRates.first?.value,
            caloriesBurned.first?.value
        )
        
        for (index, currentSample) in heartRates.enumerated() {
            let currentDate = currentSample.startDate
            let phaseDuration = currentDate.timeIntervalSince(currentPhaseStart)
            let isLastSample = index == heartRates.count - 1
            
            let phaseStats = calculatePhaseStats(
                heartRates: heartRates,
                caloriesBurned: caloriesBurned,
                startDate: currentPhaseStart,
                endDate: currentDate
            )
            
            let shouldCreatePhase = shouldCreateNewPhase(
                phaseDuration: phaseDuration,
                minPhaseDuration: minPhaseDuration,
                currentStats: phaseStats,
                previousStats: previousStats,
                thresholds: thresholds
            )
            
            if shouldCreatePhase || isLastSample {
                if isLastSample && shouldCreatePhase == false {
                    if let lastIndex = phases.indices.last {
                        phases[lastIndex].endDate = workout.endDate
                    }
                } else {
                    let phase = createWorkoutPhase(
                        startDate: currentPhaseStart,
                        endDate: currentDate,
                        stats: phaseStats,
                        globalAverages: globalAverages
                    )
                    phases.append(phase)
                    
                    currentPhaseStart = currentDate
                    previousStats = phaseStats
                }
            }
        }
        
        return phases
    }
    
    private func calculatePhaseStats(
        heartRates: [HealthData.HeartRateEntry],
        caloriesBurned: [HealthData.ActivityEntry],
        startDate: Date,
        endDate: Date
    ) -> (heartRate: Double, calorieRate: Double) {
        let phaseHeartRates = heartRates.filter { $0.startDate >= startDate && $0.endDate <= endDate }
        let phaseCalories = caloriesBurned.filter { $0.startDate >= startDate && $0.endDate <= endDate }
        let phaseDuration = endDate.timeIntervalSince(startDate)
        
        let avgHeartRate = calculateAverageHeartRate(phaseHeartRates)
        let calorieRate = calculateCaloriesBurnedRate(phaseCalories, duration: phaseDuration)
        
        return (heartRate: avgHeartRate, calorieRate: calorieRate)
    }
    
    private func shouldCreateNewPhase(
        phaseDuration: TimeInterval,
        minPhaseDuration: TimeInterval,
        currentStats: (heartRate: Double, calorieRate: Double),
        previousStats: (heartRate: Double?, calorieRate: Double?),
        thresholds: (heartRate: Double, calorieRate: Double)
    ) -> Bool {
        guard phaseDuration >= minPhaseDuration else { return false }
        
        let heartRateChanged = hasIntensityChanged(
            previousValue: previousStats.heartRate,
            currentValue: currentStats.heartRate,
            threshold: thresholds.heartRate
        )
        
        let calorieRateChanged = hasIntensityChanged(
            previousValue: previousStats.calorieRate,
            currentValue: currentStats.calorieRate,
            threshold: thresholds.calorieRate
        )
        
        return heartRateChanged || calorieRateChanged
    }
    
    private func createWorkoutPhase(
        startDate: Date,
        endDate: Date,
        stats: (heartRate: Double, calorieRate: Double),
        globalAverages: (heartRate: Double, calorieRate: Double)
    ) -> HealthData.WorkoutEntry {
        let intensityLevel = determineIntensityLevel(
            heartRate: stats.heartRate,
            caloriesBurnedRate: stats.calorieRate,
            globalHeartRate: globalAverages.heartRate,
            globalCaloriesBurnedRate: globalAverages.calorieRate
        )
        
        return HealthData.WorkoutEntry(
            startDate: startDate,
            endDate: endDate,
            value: intensityLevel,
            averageHeartRate: stats.heartRate,
            caloriesBurned: stats.calorieRate
        )
    }
    
    private func calculateAverageHeartRate(_ entries: [HealthData.HeartRateEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let totalHr = entries.reduce(0.0) { $0 + $1.value }
        
        return totalHr / Double(entries.count)
    }
    
    private func calculateCaloriesBurnedRate(_ entries: [HealthData.ActivityEntry], duration: TimeInterval) -> Double {
        guard duration > 0 else { return 0 }
        let totalCalories = entries.reduce(0.0) { $0 + $1.value }
        
        return totalCalories / duration * 60
    }
    
    private func hasIntensityChanged(previousValue: Double?, currentValue: Double, threshold: Double) -> Bool {
        guard let previousValue = previousValue else { return false }
        
        return abs(previousValue - currentValue) > threshold
    }
    
    private func determineIntensityLevel(
        heartRate: Double,
        caloriesBurnedRate: Double,
        globalHeartRate: Double,
        globalCaloriesBurnedRate: Double
    ) -> IntensityLevel {
        let heartRateRatio = heartRate / globalHeartRate
        let calorieRateRatio = caloriesBurnedRate / globalCaloriesBurnedRate
        let combinedRatio = (heartRateRatio + calorieRateRatio) / 2
        
        switch combinedRatio {
        case 0..<Constants.lowIntensityThreshold:
            return .low
        case Constants.lowIntensityThreshold..<Constants.moderateIntensityThreshold:
            return .moderate
        case Constants.moderateIntensityThreshold..<Constants.highIntensityThreshold:
            return .high
        case Constants.highIntensityThreshold...:
            return .veryHigh
        default:
            return .undetermined
        }
    }
}

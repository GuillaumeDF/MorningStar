//
//  HealthDataProcessor.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/10/2024.
//

import Foundation
import HealthKit

private enum Constants {
    static let isNightSleep: TimeInterval = 4
}

struct HealthDataProcessor {
    
    static func groupActivitiesByDay(for statsCollection: HKStatisticsCollection, from startDate: Date, to endDate: Date, unit: HKUnit) -> [PeriodEntry<HealthData.ActivityEntry>] {
        var dailyActivities: [PeriodEntry<HealthData.ActivityEntry>] = []
        var currentDayActivities: [HealthData.ActivityEntry] = []
        var currentDay: Date?
        
        statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let day = Calendar.current.startOfDay(for: statistics.startDate)
            
            if currentDay != day {
                if !currentDayActivities.isEmpty {
                    dailyActivities.insert(PeriodEntry(entries: currentDayActivities), at: 0)
                }
                currentDay = day
                currentDayActivities = []
            }
            
            if let value = statistics.sumQuantity()?.doubleValue(for: unit) {
                let entry = HealthData.ActivityEntry(
                    startDate: statistics.startDate,
                    endDate: statistics.endDate,
                    value: value,
                    unit: unit.unitString
                )
                currentDayActivities.append(entry)
            }
        }
        
        if !currentDayActivities.isEmpty {
            dailyActivities.insert(PeriodEntry(entries: currentDayActivities), at: 0)
        }
        
        return dailyActivities
    }
    
    static func groupSleepByNight(from samples: [HKSample]) -> [PeriodEntry<HealthData.SleepEntry>] {
        var nightlyActivities: [PeriodEntry<HealthData.SleepEntry>] = []
        var currentNightActivities: [HealthData.SleepEntry] = []
        var lastSampleEndDate: Date?
        
        for sample in samples {
            guard let categorySample = sample as? HKCategorySample else { continue }
            
            if let lastEnd = lastSampleEndDate, categorySample.startDate.timeIntervalSince(lastEnd) > Constants.isNightSleep * 60 * 60 {
                if !currentNightActivities.isEmpty {
                    nightlyActivities.insert(PeriodEntry(entries: currentNightActivities), at: 0)
                    currentNightActivities = []
                }
            }
            
            let entry = HealthData.SleepEntry(
                startDate: categorySample.startDate,
                endDate: categorySample.endDate,
                unit: HKUnit.hour().unitString
            )
            
            currentNightActivities.append(entry)
            lastSampleEndDate = categorySample.endDate
        }
        
        if !currentNightActivities.isEmpty {
            nightlyActivities.insert(PeriodEntry(entries: currentNightActivities), at: 0)
        }
        
        return nightlyActivities
    }
    
    static func groupWeightsByWeek(from samples: [HKSample], unit: HKUnit) -> [PeriodEntry<HealthData.WeightEntry>] {
        let calendar = Calendar.current
        
        var weeklyActivities: [PeriodEntry<HealthData.WeightEntry>] = []
        var currentWeekActivities: [HealthData.WeightEntry] = []
        var currentWeek: Date?
        
        for sample in samples {
            guard let quantitySample = sample as? HKQuantitySample else { continue }
            guard let week = calendar.dateInterval(of: .weekOfYear, for: quantitySample.startDate)?.start else { continue }
            
            if currentWeek != week {
                if !currentWeekActivities.isEmpty {
                    weeklyActivities.insert(PeriodEntry(entries: currentWeekActivities), at: 0)
                }
                currentWeek = week
                currentWeekActivities = []
            }
            
            let entry = HealthData.WeightEntry(
                startDate: sample.startDate,
                endDate: sample.endDate,
                value: quantitySample.quantity.doubleValue(for: unit),
                unit: unit.unitString
                
            )
            currentWeekActivities.append(entry)
        }
        
        if !currentWeekActivities.isEmpty {
            weeklyActivities.insert(PeriodEntry(entries: currentWeekActivities), at: 0)
        }
        
        return weeklyActivities
    }
    
    static func sortAndgroupWorkoutsByDayAndWeek(_ workouts: [HealthData.WorkoutPhaseEntries]) -> HealthData.WorkoutHistory {
        let calendar = Calendar.current
        
        let sortedWorkouts = workouts.sorted {
            ($0.first?.startDate ?? Date.distantPast) > ($1.first?.startDate ?? Date.distantPast)
        }
        
        var weeklyGroups: HealthData.WorkoutHistory = []
        var currentWeekDailyGroups: HealthData.WeeklyWorkoutSessions = []
        var currentDayWorkouts: HealthData.DailyWorkoutSessions = []
        var currentWeekStart: Date?
        var currentDayStart: Date?
        
        for workout in sortedWorkouts {
            guard let firstPhase = workout.first else { continue }
            
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstPhase.startDate))!
            let dayStart = calendar.startOfDay(for: firstPhase.startDate)
            
            if currentWeekStart != weekStart {
                if !currentDayWorkouts.isEmpty {
                    currentWeekDailyGroups.insert(currentDayWorkouts, at: 0)
                    currentDayWorkouts = []
                }
                if !currentWeekDailyGroups.isEmpty {
                    weeklyGroups.append(currentWeekDailyGroups)
                    currentWeekDailyGroups = []
                }
                currentWeekStart = weekStart
                currentDayStart = nil
            }
            
            if currentDayStart != dayStart {
                if !currentDayWorkouts.isEmpty {
                    currentWeekDailyGroups.insert(currentDayWorkouts, at: 0)
                    currentDayWorkouts = []
                }
                currentDayStart = dayStart
            }
            
            currentDayWorkouts.append(workout)
        }
        
        if !currentDayWorkouts.isEmpty {
            currentWeekDailyGroups.insert(currentDayWorkouts, at: 0)
        }
        if !currentWeekDailyGroups.isEmpty {
            weeklyGroups.append(currentWeekDailyGroups)
        }
        
        //printWeeklyGroups(weeklyGroups)
        
        return weeklyGroups
    }
}

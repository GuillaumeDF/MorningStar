//
//  HealthDataProcessor.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/10/2024.
//

import Foundation
import HealthKit

struct HealthDataProcessor {
    static func groupActivitiesByDay(for statsCollection: HKStatisticsCollection, from startDate: Date, to endDate: Date, unit: HKUnit) -> [PeriodEntry<HealthData.ActivityEntry>] {
        var dailyActivities: [PeriodEntry<HealthData.ActivityEntry>] = []
        var currentDayActivities: [HealthData.ActivityEntry] = []
        var currentDay: Date?
        
        statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let day = Calendar.current.startOfDay(for: statistics.startDate)
            
            if currentDay != day {
                if !currentDayActivities.isEmpty {
                    dailyActivities.append(PeriodEntry(entries: currentDayActivities))
                }
                currentDay = day
                currentDayActivities = []
            }
            
            let entry = HealthData.ActivityEntry(
                startDate: statistics.startDate,
                endDate: statistics.endDate,
                value: statistics.sumQuantity()?.doubleValue(for: unit) ?? -1,
                unit: unit.unitString
            )
            currentDayActivities.append(entry)
        }
        
        if !currentDayActivities.isEmpty {
            dailyActivities.append(PeriodEntry(entries: currentDayActivities))
        }
        
        return dailyActivities
    }
    
    static func groupSleepByNight(from samples: [HKSample]) -> [PeriodEntry<HealthData.SleepEntry>] {
        var nightlyActivities: [PeriodEntry<HealthData.SleepEntry>] = []
        var currentNightActivities: [HealthData.SleepEntry] = []
        var lastSampleEndDate: Date?
        
        for sample in samples {
            guard let categorySample = sample as? HKCategorySample else { continue }
            
            if let lastEnd = lastSampleEndDate, categorySample.startDate.timeIntervalSince(lastEnd) > 4 * 60 * 60 {
                if !currentNightActivities.isEmpty {
                    nightlyActivities.append(PeriodEntry(entries: currentNightActivities))
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
            nightlyActivities.append(PeriodEntry(entries: currentNightActivities))
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
                    weeklyActivities.append(PeriodEntry(entries: currentWeekActivities))
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
            weeklyActivities.append(PeriodEntry(entries: currentWeekActivities))
        }
        
        return weeklyActivities
    }
    
    static func groupWorkoutsByDayAndWeek(_ workouts: [HealthData.WorkoutPhaseEntries]) -> HealthData.WorkoutHistory {
        let calendar = Calendar.current
        
        var weeklyGroups: HealthData.WorkoutHistory = []
        var currentWeekDailyGroups: HealthData.WeeklyWorkoutSessions = []
        var currentDayWorkouts: HealthData.DailyWorkoutSessions = []
        var currentWeek: Date?
        var currentDay: Date?
        
        for workout in workouts {
            guard let firstPhase = workout.first else { continue }
            guard let week = calendar.dateInterval(of: .weekOfYear, for: firstPhase.startDate)?.start else { continue }
            guard let day = calendar.dateInterval(of: .day, for: firstPhase.startDate)?.start else { continue }
            
            if currentWeek != week {
                if !currentDayWorkouts.isEmpty {
                    currentWeekDailyGroups.append(currentDayWorkouts)
                }
                if !currentWeekDailyGroups.isEmpty {
                    weeklyGroups.append(currentWeekDailyGroups)
                }
                currentWeek = week
                currentWeekDailyGroups = []
                currentDay = nil
            }
            
            if currentDay != day {
                if !currentDayWorkouts.isEmpty {
                    currentWeekDailyGroups.append(currentDayWorkouts)
                }
                currentDay = day
                currentDayWorkouts = []
            }
            
            currentDayWorkouts.append(workout)
        }
        
        if !currentDayWorkouts.isEmpty {
            currentWeekDailyGroups.append(currentDayWorkouts)
        }
        if !currentWeekDailyGroups.isEmpty {
            weeklyGroups.append(currentWeekDailyGroups)
        }
        
        //printWeeklyGroups(weeklyGroups)
        
        return weeklyGroups
    }
}

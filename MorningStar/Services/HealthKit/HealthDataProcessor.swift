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
        let calendar = Calendar.current
        var dailyActivities: [PeriodEntry<HealthData.ActivityEntry>] = []
        var currentDayActivities: [HealthData.ActivityEntry] = []
        var currentDay: Date?
        
        statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let day = calendar.startOfDay(for: statistics.startDate)
            
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
            
            if let lastEnd = lastSampleEndDate,
               categorySample.startDate.hoursBetween(and: lastEnd) <= AppConstants.Duration.isNightSleep {
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
    
    static func sortAndgroupWorkoutsByDayAndWeek(_ workouts: [Workout]) -> [WeeklyWorkouts] {
        let calendar = Calendar.current
        var weeklyGroups: [WeeklyWorkouts] = []
        var currentWeekDailyGroups: WeeklyWorkouts = WeeklyWorkouts(dailyWorkouts: [])
        var currentDayWorkouts: DailyWorkouts = DailyWorkouts(workouts: [])
        var currentWeekStart: Date?
        var currentDayStart: Date?
        
        let sortedWorkouts = workouts.sorted {
            ($0.startDate ?? Date.distantPast) > ($1.startDate ?? Date.distantPast)
        }
        
        for workout in sortedWorkouts {
            guard let firstPhase = workout.phaseEntries.first else { continue }
            
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstPhase.startDate))!
            let dayStart = calendar.startOfDay(for: firstPhase.startDate)
            
            if currentWeekStart != weekStart {
                if !currentDayWorkouts.workouts.isEmpty {
                    currentWeekDailyGroups.dailyWorkouts.insert(currentDayWorkouts, at: 0)
                    currentDayWorkouts.workouts = []
                }
                if !currentWeekDailyGroups.dailyWorkouts.isEmpty {
                    weeklyGroups.append(currentWeekDailyGroups)
                    currentWeekDailyGroups.dailyWorkouts = []
                }
                currentWeekStart = weekStart
                currentDayStart = nil
            }
            
            if currentDayStart != dayStart {
                if !currentDayWorkouts.workouts.isEmpty {
                    currentWeekDailyGroups.dailyWorkouts.insert(currentDayWorkouts, at: 0)
                    currentDayWorkouts.workouts = []
                }
                currentDayStart = dayStart
            }
            
            currentDayWorkouts.workouts.append(workout)
        }
        
        if !currentDayWorkouts.workouts.isEmpty {
            currentWeekDailyGroups.dailyWorkouts.insert(currentDayWorkouts, at: 0)
        }
        if !currentWeekDailyGroups.dailyWorkouts.isEmpty {
            weeklyGroups.append(currentWeekDailyGroups)
        }
        
        return weeklyGroups
    }
}

extension HealthDataProcessor {
    static func groupActivitiesByDay(from samples: [HKSample], unit: HKUnit) -> [PeriodEntry<HealthData.ActivityEntry>] {
        let calendar = Calendar.current
        var dailyActivities: [PeriodEntry<HealthData.ActivityEntry>] = []
        var currentDayActivities: [HealthData.ActivityEntry] = []
        var currentDay: Date?
        let inactivityThreshold: TimeInterval = 5 * 60 // 5 minutes
        
        for sample in samples {
            guard let quantitySample = sample as? HKQuantitySample else { continue }
            guard let device = sample.device, // TODO: A refaire
                  let model = device.model,
                  model.contains("Watch") else {
                continue
            }
            let day = calendar.startOfDay(for: quantitySample.startDate)
            
            if currentDay != day {
                if !currentDayActivities.isEmpty {
                    dailyActivities.insert(PeriodEntry(entries: currentDayActivities), at: 0)
                }
                currentDay = day
                currentDayActivities = []
            }
            
            let entry = HealthData.ActivityEntry(
                startDate: quantitySample.startDate,
                endDate: quantitySample.endDate,
                value: quantitySample.quantity.doubleValue(for: unit),
                unit: unit.unitString
            )
            
            if let lastEntry = currentDayActivities.last {
                let timeDifference = entry.startDate.timeIntervalSince(lastEntry.endDate)
                if timeDifference <= inactivityThreshold{
                    // Fusionner avec la dernière entrée
                    let mergedEntry = HealthData.ActivityEntry(
                        startDate: lastEntry.startDate,
                        endDate: entry.endDate,
                        value: lastEntry.value + entry.value,
                        unit: unit.unitString
                    )
                    currentDayActivities[currentDayActivities.count - 1] = mergedEntry
                } else {
                    // Ajouter une entrée avec 0 pas pour la période d'inactivité
                    if timeDifference > inactivityThreshold {
                        let inactivityEntry = HealthData.ActivityEntry(
                            startDate: lastEntry.endDate,
                            endDate: entry.startDate,
                            value: 0,
                            unit: unit.unitString
                        )
                        currentDayActivities.append(inactivityEntry)
                    }
                    currentDayActivities.append(entry)
                }
            } else {
                currentDayActivities.append(entry)
            }
        }
        
        if !currentDayActivities.isEmpty {
            dailyActivities.insert(PeriodEntry(entries: currentDayActivities), at: 0)
        }
        
        return dailyActivities
    }
}

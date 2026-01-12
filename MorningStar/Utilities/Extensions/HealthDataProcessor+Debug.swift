//
//  HealthDataProcessor+Debug.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 16/10/2024.
//

import Foundation

extension HealthDataProcessor {
    static func printWeeklyGroups(_ weeklyGroups: [WeeklyWorkouts]) {
        let dateFormatter = AppConstants.DateFormatters.debug
        
        for (weekIndex, week) in weeklyGroups.enumerated() {
            print("Semaine \(weekIndex + 1)")
            for (dayIndex, day) in week.dailyWorkouts.enumerated() {
                print("  Jour \(dayIndex + 1)")
                for (entryIndex, entries) in day.workouts.enumerated() {
                    print("    Entrée \(entryIndex + 1)")
                    for entry in entries.phaseEntries {
                        print("      Hash: \(entry.hashValue)")
                        print("      Début: \(dateFormatter.string(from: entry.startDate))")
                        print("      Fin: \(dateFormatter.string(from: entry.endDate))")
                        print("      Valeur: \(entry.value) \(entry.unit)")
                        print("------------------------------------------------------------")
                    }
                }
            }
            print()
        }
    }
}

//
//  HealthDataProcessor+Debug.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 16/10/2024.
//

import Foundation

extension HealthDataProcessor {
    static func printWeeklyGroups(_ weeklyGroups: HealthData.WorkoutHistory) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for (weekIndex, week) in weeklyGroups.enumerated() {
            print("Semaine \(weekIndex + 1):")
            for (dayIndex, day) in week.enumerated() {
                print("  Jour \(dayIndex + 1):")
                for (entryIndex, entries) in day.enumerated() {
                    print("    Entrée \(entryIndex + 1):")
                    for entry in entries {
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

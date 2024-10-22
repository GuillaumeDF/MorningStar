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
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        for (weekIndex, week) in weeklyGroups.enumerated() {
            print("Semaine \(weekIndex + 1): \(week.hashValue)")
            for (dayIndex, day) in week.enumerated() {
                print("  Jour \(dayIndex + 1): \(day.hashValue)")
                for (entryIndex, entries) in day.enumerated() {
                    print("    Entrée \(entryIndex + 1): \(entries.hashValue)")
                    for entry in entries {
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

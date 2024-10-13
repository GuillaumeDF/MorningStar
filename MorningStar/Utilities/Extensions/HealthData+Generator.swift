//
//  HealthData+Generator.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 25/09/2024.
//

import Foundation

extension HealthData {
    static func fakeStepCountHistory() -> [PeriodEntry<ActivityEntry>] {
        var stepHistory: [PeriodEntry<ActivityEntry>] = []
        let calendar = Calendar.current
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let stepCount = Double(Int.random(in: 2000...12000))
            let activityEntry = ActivityEntry(
                startDate: date,
                endDate: calendar.date(byAdding: .hour, value: 1, to: date)!,
                value: stepCount, 
                unit: "steps"
            )
            let dailyActivity = PeriodEntry<ActivityEntry>(entries: [activityEntry])
            
            stepHistory.append(dailyActivity)
        }
        
        return stepHistory
    }
}

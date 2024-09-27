//
//  HealthData+Generator.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 25/09/2024.
//

import Foundation

extension HealthData {
    static func fakeStepCountHistory() -> [PeriodActivity<ActivityEntry>] {
        var stepHistory: [PeriodActivity<ActivityEntry>] = []
        let calendar = Calendar.current
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let stepCount = Double(Int.random(in: 2000...12000))
            let activityEntry = ActivityEntry(
                start: date,
                end: calendar.date(byAdding: .hour, value: 1, to: date),
                measurement: Measurement(value: stepCount, unit: "steps")
            )
            let dailyActivity = PeriodActivity<ActivityEntry>(activities: [activityEntry])
            
            stepHistory.append(dailyActivity)
        }
        
        return stepHistory
    }
}

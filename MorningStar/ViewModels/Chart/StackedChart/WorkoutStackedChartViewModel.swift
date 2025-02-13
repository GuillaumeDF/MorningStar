//
//  WorkoutStackedChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

class WorkoutStackedChartViewModel: ActivityDataProvider, ActivityDisplayable, IndexManageable {
    typealias EntryType = WeeklyWorkouts
    
    @Published var index: Int
    @Published var periods: [EntryType] {
        didSet {
            isEmpty = periods.isEmpty
        }
    }
    
    var isEmpty: Bool
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd/MM"
        
        return formatter
    }()
    
    init(workoutHistory: [EntryType]) {
        self.periods = workoutHistory
        self.index = 0
        self.isEmpty = workoutHistory.isEmpty
    }
    
    var currentPeriod: EntryType {
        periods[index]
    }
    
    
    var currentDateLabel: DateRepresentation {
        .multiple(
            periods[index]
                .dailyWorkouts
                .map { workoutPhases in
                    if let startDate = workoutPhases.startDate {
                        return dateFormatter.string(from: startDate)
                    } else {
                        return "???"
                    }
                }
        )
    }
    
    var maxTime: CGFloat {
        return ceil(
            (
                periods[index]
                    .dailyWorkouts
                    .map { dailyWorkout in
                        dailyWorkout.workouts.reduce(0) { total, workout in
                            if let startDate = workout.startDate, let endDate = workout.endDate {
                                total + endDate.timeIntervalSince(startDate)
                            } else {
                                total + 0
                            }
                        }
                    }
                    .max() ?? 0
            ) / 60 / 10
        ) * 10
    }
    
    var data: ChartData { ChartData.empty }
    
    var currentValueLabel: String { "" }
    
    var unitLabel: String { "" }
    
    func valueGraphFormatter(_ value: Double, at date: Date) -> String {
        ""
    }
}

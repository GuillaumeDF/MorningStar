//
//  WorkoutStackedChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation
import Observation

@Observable
class WorkoutStackedChartViewModel: ActivityDataProvider, ActivityDisplayable, IndexManageable {
    typealias EntryType = WeeklyWorkouts

    var index: Int {
        didSet {
            recalculateCachedValues()
        }
    }
    var periods: [EntryType] {
        didSet {
            isEmpty = periods.isEmpty
            recalculateCachedValues()
        }
    }

    var isEmpty: Bool

    // Cached computed values
    private(set) var currentDateLabel: DateRepresentation = .multiple([])
    private(set) var maxTime: CGFloat = 0

    var dateFormatter: DateFormatter {
        AppConstants.DateFormatters.dayMonth
    }

    init(workoutHistory: [EntryType]) {
        self.periods = workoutHistory
        self.index = 0
        self.isEmpty = workoutHistory.isEmpty
        recalculateCachedValues()
    }

    var currentPeriod: EntryType {
        periods[index]
    }

    private func recalculateCachedValues() {
        guard !periods.isEmpty, index < periods.count else {
            currentDateLabel = .multiple([])
            maxTime = 0
            return
        }

        // Cache currentDateLabel
        currentDateLabel = .multiple(
            periods[index]
                .dailyWorkouts.flatMap { dailyWorkout in
                    dailyWorkout.workouts.map { workout in
                        if let startDate = workout.startDate {
                            return dateFormatter.string(from: startDate)
                        } else {
                            return "???"
                        }
                    }
                }
        )

        // Cache maxTime
        maxTime = ceil(
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
    
    var data: [ChartData] { [] }
    
    var currentValueLabel: String { "" }
    
    var unitLabel: String { "" }
    
    func valueFormatter(_ value: Double) -> String { "" }
    
    func dateFormatter(_ date: Date) -> String { "" }
}

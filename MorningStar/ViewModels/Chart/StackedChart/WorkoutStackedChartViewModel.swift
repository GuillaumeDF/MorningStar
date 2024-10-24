//
//  WorkoutStackedChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

class WorkoutStackedChartViewModel: ActivityDataProvider, ActivityDisplayable, IndexManageable {
    typealias EntryType = HealthData.WeeklyWorkoutSessions
    
    @Published var index: Int
    @Published var periods: [EntryType] {
        didSet {
            isEmpty = periods.isEmpty
        }
    }
    
    var isEmpty: Bool
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
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
                .flatMap { $0 }
                .map { workoutPhases in
                    if let startDate = workoutPhases.first?.startDate {
                        return dateFormatter.string(from: startDate)
                    } else {
                        return "???"
                    }
                }
        )
    }
    
    var maxTime: CGFloat {
        return (
            periods[index]
                .flatMap { $0 }
                .map { workoutPhases in
                    workoutPhases.reduce(0) { total, phase in
                        total + phase.endDate.timeIntervalSince(phase.startDate)
                    }
                }
                .max() ?? 0
        ) / 60
    }
    
    var allValues: [Double] { [] }
    
    var currentValueLabel: String { "" }
    
    var unitLabel: String { "" }
}

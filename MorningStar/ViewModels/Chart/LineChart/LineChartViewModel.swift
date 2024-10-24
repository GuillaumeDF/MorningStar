//
//  LineChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

class LineChartViewModel<T: HealthEntry>: ActivityDataProvider, ActivityDisplayable, PeriodSelectable  {
    typealias EntryType = PeriodEntry<T>
    
    @Published var index: Int
    @Published var periods: [EntryType] {
        didSet {
            isEmpty = periods.isEmpty
        }
    }
    
    var isEmpty: Bool
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(activityPeriods: [EntryType]) {
        self.periods = activityPeriods
        self.index = 0
        self.isEmpty = activityPeriods.isEmpty
    }
    
    var currentPeriod: EntryType {
        periods[index]
    }
    
    var currentDateLabel: DateRepresentation { .single("") }
    
    var currentValueLabel: String { "" }
    
    var unitLabel: String {
        periods[index].entries.first?.unit ?? "none"
    }
    
    var allValues: [Double] {
        periods[index].entries.map {
            if let doubleValue = $0.value as? Double {
                return doubleValue
            } else if let timeIntervalValue = $0.value as? TimeInterval {
                return Double(timeIntervalValue)
            } else {
                return 0
            }
        }
    }
    
    func selectPreviousPeriod() {
        guard canSelectPreviousPeriod else { return }
        index += 1
    }
    
    func selectNextPeriod() {
        guard canSelectNextPeriod else { return }
        index -= 1
    }
    
    var canSelectPreviousPeriod: Bool {
        index < periods.count - 1
    }
    
    var canSelectNextPeriod: Bool {
        index > 0
    }
    
    var activityTrend: ArrowDirection {
        guard canSelectPreviousPeriod else {
            return .up
        }
        
        let previousEntries = periods[index + 1].entries
        
        let totalPreviousEntries = previousEntries.reduce(0) { sum, entry in
            if let value = entry.value as? Double {
                return sum + value
            } else if let timeIntervalValue = entry.value as? TimeInterval {
                return sum + Double(timeIntervalValue)
            } else {
                return sum
            }
        }
        
        let totalCurrentEntries = allValues.reduce(0, +)
        
        return totalPreviousEntries > totalCurrentEntries ? .down : .up
    }
}

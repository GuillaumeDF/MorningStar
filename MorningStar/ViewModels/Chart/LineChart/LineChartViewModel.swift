//
//  LineChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation
import Observation

struct ChartData {
    let value: Double
    let startDate: Date
    let endDate: Date

    static let empty = ChartData(value: 0, startDate: .distantPast, endDate: .distantPast)
}

@Observable
class LineChartViewModel<T: HealthEntry>: ActivityDataProvider, ActivityDisplayable, PeriodSelectable  {
    typealias EntryType = PeriodEntry<T>

    var index: Int
    var periods: [EntryType] {
        didSet {
            isEmpty = periods.isEmpty
        }
    }

    var isEmpty: Bool

    var dateFormatter: DateFormatter {
        AppConstants.DateFormatters.mediumDate
    }

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
        periods[index].entries.first?.unit ?? "?"
    }
    
    var data: [ChartData] {
        periods[index].entries.compactMap { entry in
            guard let value = entry.value as? Double else {
                return nil
            }
            return ChartData(value: value, startDate: entry.startDate, endDate: entry.endDate)
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
        
        let totalCurrentEntries = data.map { $0.value }.reduce(0, +)
        
        return totalPreviousEntries > totalCurrentEntries ? .down : .up
    }
    
    func valueFormatter(_ value: Double) -> String { "" }
    
    func dateFormatter(_ date: Date) -> String { "" }
}

extension LineChartViewModel {
    func fillGapsWithZeros() -> [Double] { // TODO: Refaire une extension généric de EntryType ?
        guard !currentPeriod.entries.isEmpty else { return [] }
        
        var result: [Double] = []
        
        for (index, entry) in currentPeriod.entries.enumerated() {
            if let value = Double(String(describing: entry.value)) {
                result.append(value)
                
                if index < currentPeriod.entries.count - 1 {
                    let currentEnd = entry.endDate
                    let nextStart = currentPeriod.entries[index + 1].startDate
                    
                    let numberOfHours = currentEnd.hoursBetween(and: nextStart)
                    
                    if numberOfHours > 0 {
                        result.append(contentsOf: repeatElement(0.0, count: numberOfHours))
                    }
                }
            }
        }
        
        return result
    }
}

//
//  BaseLineChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 27/09/2024.
//

import Foundation

protocol MSLineChartCardViewModelProtocol: ObservableObject {
    associatedtype EntryType
    
    var activityPeriods: [EntryType] { get set }
    var selectedPeriodIndex: Int { get set }
    var selectedPeriodActivity: EntryType { get }
    var formattedSelectedDate: String { get }
    var formattedSelectedValue: String { get }
    var selectedActivityUnit: String { get }
    var activityValues: [Double] { get }
    
    func selectPreviousPeriod()
    func selectNextPeriod()
    var canSelectPreviousPeriod: Bool { get }
    var canSelectNextPeriod: Bool { get }
}

class BaseLineChartViewModel<T: HealthEntry>: MSLineChartCardViewModelProtocol {
    typealias EntryType = PeriodEntry<T>
    
    @Published var selectedPeriodIndex: Int
    
    var activityPeriods: [EntryType]
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(activityPeriods: [EntryType]) {
        self.activityPeriods = activityPeriods
        self.selectedPeriodIndex = activityPeriods.count - 1
    }
    
    var selectedPeriodActivity: EntryType {
        activityPeriods[selectedPeriodIndex]
    }
    
    var formattedSelectedDate: String { "" }
    
    var formattedSelectedValue: String { "" }
    
    var selectedActivityUnit: String {
        activityPeriods[selectedPeriodIndex].entries.first?.unit ?? "none"
    }
    
    var activityValues: [Double] {
        activityPeriods[selectedPeriodIndex].entries.map {
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
        selectedPeriodIndex -= 1
    }
    
    func selectNextPeriod() {
        guard canSelectNextPeriod else { return }
        selectedPeriodIndex += 1
    }
    
    var canSelectPreviousPeriod: Bool {
        selectedPeriodIndex > 0
    }
    
    var canSelectNextPeriod: Bool {
        selectedPeriodIndex < activityPeriods.count - 1
    }
}

class WeightLineChartViewModel: BaseLineChartViewModel<HealthData.WeightEntry> {
    override var formattedSelectedDate: String {
        guard let startDate = activityPeriods[selectedPeriodIndex].entries.first?.startDate,
              let endDate = activityPeriods[selectedPeriodIndex].entries.last?.startDate else {
            return "Aucune date"
        }
        
        return startDate == endDate
        ? dateFormatter.string(from: startDate)
        : "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
    }
    
    override var formattedSelectedValue: String {
        let value = activityPeriods[selectedPeriodIndex].entries.last?.value ?? 0.0
        let roundedValue = (value * 100).rounded() / 100
        
        return String(format: "%.2f", roundedValue)
   }
}

class ActivityLineChartViewModel: BaseLineChartViewModel<HealthData.ActivityEntry> {
    override var formattedSelectedDate: String {
        if let startDate = activityPeriods[selectedPeriodIndex].entries.first?.startDate {
            return "\(dateFormatter.string(from: startDate))"
        } else {
            return "Aucune date"
        }
    }
    
    override var formattedSelectedValue: String {
        let totalValue = activityPeriods[selectedPeriodIndex].entries.reduce(0) { $0 + $1.value }
        
        return String(Int(totalValue))
    }
}


class SleepLineChartViewModel: BaseLineChartViewModel<HealthData.SleepEntry> {
    override var formattedSelectedDate: String {
        if let startDate = activityPeriods[selectedPeriodIndex].entries.first?.startDate {
            return "\(dateFormatter.string(from: startDate))"
        } else {
            return "Aucune date"
        }
    }
    
    override var formattedSelectedValue: String {
        let totalSeconds = activityPeriods[selectedPeriodIndex].entries.reduce(0) { $0 + $1.value }
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if minutes == 0 {
            return "\(hours)\(activityPeriods[selectedPeriodIndex].entries.first?.unit ?? "")"
        } else {
            return "\(hours)\(activityPeriods[selectedPeriodIndex].entries.first?.unit ?? "") \(minutes)"
        }
    }
    
    override var selectedActivityUnit: String { "" }
}

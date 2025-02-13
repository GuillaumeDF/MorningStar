//
//  WeightLineChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

class WeightLineChartViewModel: LineChartViewModel<HealthData.WeightEntry> {
    override var currentDateLabel: DateRepresentation {
        dateFormatter.dateFormat = "d MMM yyyy"
        
        guard let startDate = periods[index].entries.first?.startDate,
              let endDate = periods[index].entries.last?.startDate else {
            return .single("Aucune date")
        }
        
        return .single(startDate == endDate
                       ? dateFormatter.string(from: startDate)
                       : "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))")
    }
    
    override var currentValueLabel: String {
        let value = periods[index].entries.last?.value ?? 0.0
        let roundedValue = (value * 100).rounded() / 100
        
        return String(format: "%.2f", roundedValue)
   }
    
    override var activityTrend: ArrowDirection {
        guard canSelectPreviousPeriod,
              let previousEntry = periods[index + 1].entries.last,
              let currentEntry = periods[index].entries.last else {
            return .up
        }
        
        return previousEntry.value > currentEntry.value ? .down : .up
    }
    
    override func valueFormatter(_ value: Double) -> String {
        "\(String(format: "%.2f", value)) \(unitLabel)"
    }
    
    override func dateFormatter(_ date: Date) -> String {
        dateFormatter.dateFormat = "EEEE HH:mm"
        let dateString = dateFormatter.string(from: date)
        
        return "\(dateString)"
    }
}

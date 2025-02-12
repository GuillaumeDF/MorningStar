//
//  ActivityLineChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

class ActivityLineChartViewModel: LineChartViewModel<HealthData.ActivityEntry> {
    override var currentDateLabel: DateRepresentation {
        dateFormatter.dateFormat = "d MMM yyyy"
        
        if let startDate = periods[index].entries.first?.startDate {
            return .single("\(dateFormatter.string(from: startDate))")
        } else {
            return .single("Aucune date")
        }
    }
    
    override var currentValueLabel: String {
        let totalValue = periods[index].entries.reduce(0) { $0 + $1.value }
        
        return String(Int(totalValue))
    }
    
    override func valueGraphFormatter(_ value: Double, at date: Date) -> String {
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: date)
        
        return "\(dateString): \(String(format: "%.0f", value.rounded())) \(unitLabel)"
    }
}

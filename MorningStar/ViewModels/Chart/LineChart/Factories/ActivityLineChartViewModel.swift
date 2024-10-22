//
//  ActivityLineChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

class ActivityLineChartViewModel: LineChartViewModel<HealthData.ActivityEntry> {
    override var currentDateLabel: DateRepresentation {
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
}

//
//  SleepLineChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

class SleepLineChartViewModel: LineChartViewModel<HealthData.SleepEntry> {
    override var currentDateLabel: DateRepresentation {
        dateFormatter.dateFormat = "d MMM yyyy"
        
        if let startDate = periods[index].entries.first?.startDate {
            return .single("\(dateFormatter.string(from: startDate))")
        } else {
            return .single("Aucune date")
        }
    }
    
    override var currentValueLabel: String {
        let totalSeconds = periods[index].entries.reduce(0) { $0 + $1.value }
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if minutes == 0 {
            return "\(hours)\(periods[index].entries.first?.unit ?? "")"
        } else {
            return "\(hours)\(periods[index].entries.first?.unit ?? "") \(minutes)"
        }
    }
    
    override var unitLabel: String { "" }
    
    override func valueGraphFormatter(_ value: Double, at date: Date) -> String {
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: date)
        
        return "\(dateString): \(String(format: "%.0f", (value / 60).rounded())) min"
    }
}

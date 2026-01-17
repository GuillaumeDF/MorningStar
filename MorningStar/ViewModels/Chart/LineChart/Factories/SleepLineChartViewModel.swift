//
//  SleepLineChartViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

class SleepLineChartViewModel: LineChartViewModel<HealthData.SleepEntry> {
    override var currentDateLabel: DateRepresentation {
        if let startDate = periods[index].entries.first?.startDate {
            return .single(DateFormatters.dayMonthYear.string(from: startDate))
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

    override func valueFormatter(_ value: Double) -> String {
        "\(String(format: "%.0f", (value / 60).rounded())) min"
    }

    override func dateFormatter(_ date: Date) -> String {
        return DateFormatters.time.string(from: date)
    }
}

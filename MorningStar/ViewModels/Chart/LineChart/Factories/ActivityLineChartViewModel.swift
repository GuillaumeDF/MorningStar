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
            return .single(DateFormatters.dayMonthYear.string(from: startDate))
        } else {
            return .single("Aucune date")
        }
    }

    override var currentValueLabel: String {
        let totalValue = periods[index].entries.reduce(0) { $0 + $1.value }

        return String(Int(totalValue))
    }

    override var data: [ChartData] {
        var mappedData = super.data

        guard let startData = mappedData.first?.startDate,
              let endData = mappedData.last?.endDate else {
            return mappedData
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startData)
        let endOfDay = min(startOfDay.addingTimeInterval(24 * 60 * 60), Date())

        if startData > startOfDay {
            let fillerStart = ChartData(value: 0.0, startDate: startOfDay, endDate: startData)
            mappedData = [fillerStart] + mappedData
        }

        if endData < endOfDay {
            let fillerEnd = ChartData(value: 0.0, startDate: endData, endDate: endOfDay)
            mappedData.append(fillerEnd)
        }

        return mappedData
    }

    override func valueFormatter(_ value: Double) -> String {
        "\(String(format: "%.0f", value.rounded())) \(unitLabel)"
    }

    override func dateFormatter(_ date: Date) -> String {
        return DateFormatters.time.string(from: date)
    }
}

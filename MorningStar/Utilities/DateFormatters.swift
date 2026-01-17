//
//  DateFormatters.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 17/01/2026.
//

import Foundation

enum DateFormatters {
    static let dayMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let weekdayTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE HH:mm"
        return formatter
    }()
}

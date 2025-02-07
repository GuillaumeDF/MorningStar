//
//  Date.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/02/2025.
//

import Foundation

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        
        let day1 = formatter.string(from: self)
        let day2 = formatter.string(from: otherDate)
        
        return day1 == day2
    }
}

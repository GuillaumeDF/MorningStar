//
//  Date.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/02/2025.
//

import Foundation

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        return utcCalendar.isDate(self, inSameDayAs: otherDate)
    }
    
    func isSameWeek(as otherDate: Date) -> Bool {
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        return utcCalendar.isDate(self, equalTo: otherDate, toGranularity: .weekOfYear)
    }
}

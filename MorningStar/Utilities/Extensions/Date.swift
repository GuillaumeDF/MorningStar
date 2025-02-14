//
//  Date.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/02/2025.
//

import Foundation

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
    
    func isSameWeek(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(self, equalTo: otherDate, toGranularity: .weekOfYear)
    }
}

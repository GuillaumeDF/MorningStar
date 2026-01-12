//
//  Constants.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 09/08/2024.
//

import SwiftUI

enum AppConstants {
    enum Accessibility {
        static let minimumTouchTarget: CGFloat = 44
    }

    enum DateFormatters {
        static let mediumDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = .current
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }()

        static let dayMonth: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = .current
            formatter.dateFormat = "dd/MM"
            return formatter
        }()

        static let debug: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            return formatter
        }()
    }

    enum Padding {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    enum Radius {
        static let extraSmall: CGFloat = 2
        static let small: CGFloat = 5
        static let medium: CGFloat = 10
        static let large: CGFloat = 15
        static let extraLarge: CGFloat = 20
    }
    
    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
    
    enum Duration {
        // Time is measured in seconds
        static let rateLimitSleep: UInt64 = 60
        static let syncRetryDelay: Double = 300
        
        // Time is measured in hours
        static let isNightSleep: Int = 4
    }
}

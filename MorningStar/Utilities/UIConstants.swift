//
//  UIConstants.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 09/08/2024.
//

import SwiftUI

enum AppConstants {
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
    
    // Time is measured in seconds
    enum TimeDelay {
        static let rateLimitSleep: UInt64 = 60
        static let syncRetryDelay: Double = 300
    }
}

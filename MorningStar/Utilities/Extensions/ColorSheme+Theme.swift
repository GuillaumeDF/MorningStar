//
//  ColorSheme+Theme.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 27/08/2024.
//

import SwiftUI

extension ColorScheme {
    var description: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        @unknown default:
            return "Light"
        }
    }
    
    var iconName: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        @unknown default:
            return "sun.max.fill"
        }
    }
}

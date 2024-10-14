//
//  HealthKitError.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation

enum HealthKitError: Error {
    case dataProcessingFailed
    case queryFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .dataProcessingFailed:
            return "Failed to process the HealthKit data."
        case .queryFailed(let error):
            return error.localizedDescription
        }
    }
}

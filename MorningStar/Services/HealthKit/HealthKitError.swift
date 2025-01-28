//
//  HealthKitError.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation

enum HealthKitError: Error {
    case dataProcessingFailed
    case unsupportedDataType
    case queryFailed(Error)
    case managerCreationFailed
    
    var localizedDescription: String {
        switch self {
        case .dataProcessingFailed:
            return "Failed to process the HealthKit data."
        case .unsupportedDataType:
            return "dataProcessingFailed"
        case .queryFailed(let error):
            return error.localizedDescription
        case .managerCreationFailed:
            return "managerCreationFailed"
        }
    }
}

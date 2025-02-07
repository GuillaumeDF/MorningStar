//
//  HealthKitError.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/10/2024.
//

import Foundation

enum HealthKitError: Error {
    case dataProcessingFailure
    case unsupportedDataType
    case queryExecutionFailure(Error)
    case healthKitManagerInitializationFailure
    case authorizationDenied
    
    var localizedDescription: String {
        switch self {
        case .dataProcessingFailure:
            return "Unable to process HealthKit data."
        case .unsupportedDataType:
            return "The provided data type is not supported by HealthKit."
        case .queryExecutionFailure(let error):
            return "HealthKit query failed: \(error.localizedDescription)"
        case .healthKitManagerInitializationFailure:
            return "Failed to initialize the HealthKit manager."
        case .authorizationDenied:
            return "HealthKit authorization was denied."
        }
    }
}

//
//  CoreDataError.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/02/2025.
//

import Foundation

enum CoreDataError: Error {
    case unsupportedDataType
    case storeLoadFailure(Error)

    var localizedDescription: String {
        switch self {
        case .unsupportedDataType:
            return "The provided data type is not supported by CoreData."
        case .storeLoadFailure(let underlyingError):
            return "Failed to load persistent store: \(underlyingError.localizedDescription)"
        }
    }
}

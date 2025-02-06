//
//  CoreDataError.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/02/2025.
//

import Foundation

enum CoreDataError: Error {
    case unsupportedDataType

    
    var localizedDescription: String {
        switch self {
        case .unsupportedDataType:
            return "The provided data type is not supported by CoreData."
        }
    }
}

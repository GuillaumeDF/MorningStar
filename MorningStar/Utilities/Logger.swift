//
//  Logger.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/02/2025.
//

struct Logger {
    static func logInfo(_ metric: HealthMetricType, message: String) {
        let formattedMessage = "\(metric.debugSymbol)  [\(metric.description)] : \(message)"
        print(formattedMessage)
    }
    
    static func logWarning(_ metric: HealthMetricType, message: String) {
        let formattedMessage = "⚠️  [\(metric.description)] : \(message)"
        print(formattedMessage)
    }
    
    static func logError(_ metric: HealthMetricType, message: String) {
        let formattedMessage = "❌  [\(metric.description)] : \(message)"
        print(formattedMessage)
    }
    
    static func logError(_ metric: HealthMetricType, error: Error) {
        logError(metric, message: error.localizedDescription)
    }
    
    static func logError(error: Error) {
        let formattedMessage = "❌  \(error.localizedDescription)"
        print(formattedMessage)
    }
    
    static func logError(message: String) {
        let formattedMessage = "❌  \(message)"
        print(formattedMessage)
    }

    static func logInfo(message: String) {
        let formattedMessage = "ℹ️  \(message)"
        print(formattedMessage)
    }

    static func logWarning(message: String) {
        let formattedMessage = "⚠️  \(message)"
        print(formattedMessage)
    }
}

//
//  SyncStorage.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import Foundation

protocol SyncStorage {
    func getLastSync(for type: HealthMetricType) async -> Date?
    func updateLastSync(for type: HealthMetricType) async
    func clearSyncHistory() async
}

class LastSyncStorage: SyncStorage {
    private let userDefaults: UserDefaults
    private let keyPrefix = "healthSync"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getLastSync(for type: HealthMetricType) async -> Date? {
        return userDefaults.object(forKey: makeKey(for: type)) as? Date
    }
    
    func updateLastSync(for type: HealthMetricType) async {
        let calendar = Calendar.current
        let now = Date()

        // Récupérer les composants de la date d'hier
        var components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: -1, to: now)!)

        // Définir l'heure à 15h
        components.hour = 15
        components.minute = 0
        components.second = 0
        userDefaults.set(Date(), forKey: makeKey(for: type))
    }
    
    func clearSyncHistory() async {
        for type in HealthMetricType.allCases {
            userDefaults.removeObject(forKey: makeKey(for: type))
        }
    }
    
    private func makeKey(for type: HealthMetricType) -> String {
        return "\(keyPrefix)_\(type.description)"
    }
}

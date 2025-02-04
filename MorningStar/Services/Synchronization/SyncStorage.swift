//
//  SyncStorage.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import Foundation

protocol SyncStorage {
    func getLastSync(for type: HealthDataType) async -> Date?
    func updateLastSync(for type: HealthDataType) async
    func clearSyncHistory() async
}

class LastSyncStorage: SyncStorage {
    private let userDefaults: UserDefaults
    private let keyPrefix = "healthSync"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getLastSync(for type: HealthDataType) async -> Date? {
        return userDefaults.object(forKey: makeKey(for: type)) as? Date
    }
    
    func updateLastSync(for type: HealthDataType) async {
        userDefaults.set(Date(), forKey: makeKey(for: type))
    }
    
    func clearSyncHistory() async {
        for type in HealthDataType.allCases {
            userDefaults.removeObject(forKey: makeKey(for: type))
        }
    }
    
    private func makeKey(for type: HealthDataType) -> String {
        return "\(keyPrefix)_\(type.description)"
    }
}

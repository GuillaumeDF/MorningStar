//
//  SyncStrategy.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import Foundation

protocol SyncStrategy {
    func shouldSync(lastSync: Date?) -> Bool
}

struct TimeBasedSyncStrategy: SyncStrategy {
    let minimumInterval: TimeInterval
    
    func shouldSync(lastSync: Date?) -> Bool {
        guard let lastSync = lastSync else { return true }
        return Date().timeIntervalSince(lastSync) >= minimumInterval
    }
}

struct AlwaysSyncStrategy: SyncStrategy {
    func shouldSync(lastSync: Date?) -> Bool {
        return true
    }
}

struct NeverSyncStrategy: SyncStrategy {
    func shouldSync(lastSync: Date?) -> Bool {
        return false
    }
}

//
//  HealthRepository.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import Foundation

protocol HealthRepositoryProtocol {
    func fetchCoreData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws -> [T.HealthDataType]
    func syncData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws -> [T.HealthDataType]
}

class HealthRepository: HealthRepositoryProtocol {
    private let coreDataSource: CoreDataSourceProtocol
    private let healthKitSource: HealthKitSourceProtocol
    
    private let syncStrategy: SyncStrategy
    private let syncStorage: SyncStorage
    
    init(
        coreDataSource: CoreDataSourceProtocol,
        healthKitSource: HealthKitSourceProtocol,
        syncStrategy: SyncStrategy,
        syncStorage: SyncStorage
    ) {
        self.coreDataSource = coreDataSource
        self.healthKitSource = healthKitSource
        self.syncStrategy = syncStrategy
        self.syncStorage = syncStorage
    }
    
    func fetchCoreData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws -> [T.HealthDataType] {
        let localData = try await coreDataSource.fetch(factory, options: .dateDescending)
        let healthData = factory.mapCoreDataToHealthKit(localData)
        
        return healthData
    }
    
    func fetchHealthKit<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date) async throws -> [T.HealthDataType] {
        return try await healthKitSource.fetch(factory, from: startDate, to: nil)
    }
    
    func mergeCoreDataWithHealthKitData<T: HealthDataFactoryProtocol>(_ factory: T.Type, localData: [T.CoreDataType], with healthKitData: [T.HealthDataType]) async throws -> [T.HealthDataType] {
        let newEntries = coreDataSource.mergeCoreDataWithHealthKitData(factory, localData: localData, with: healthKitData)
        try coreDataSource.save()
        
        return factory.mapCoreDataToHealthKit(newEntries)
    }

    func syncData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws -> [T.HealthDataType] {
        let lastSync = await syncStorage.getLastSync(for: factory.id) ?? Date.distantPast
        Logger.logInfo(factory.id, message: "The last synchronization time retrieved is \(lastSync)")
        
        guard syncStrategy.shouldSync(lastSync: lastSync) else {
            Logger.logInfo(factory.id, message: "No synchronization is required at this time.")
            return []
        }
        
        let newItemsHealthKit = try await fetchHealthKit(factory, from: lastSync)
        Logger.logInfo(factory.id, message: "A new synchronization attempt has been initiated at \(lastSync).")
        guard !newItemsHealthKit.isEmpty else {
            Logger.logInfo(factory.id, message: "No new items were retrieved from HealthKit.")
            return []
        }
        
        let dataFetched = try coreDataSource.getDataFetched(factory)
        let newItemsMerged = try await mergeCoreDataWithHealthKitData(factory, localData: dataFetched, with: newItemsHealthKit)
        
        await syncStorage.updateLastSync(for: factory.id)
        Logger.logInfo(factory.id, message: "The last synchronization time has been updated to \(Date())")
        
        return newItemsMerged
    }
}

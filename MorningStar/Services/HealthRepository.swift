//
//  HealthRepository.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import Foundation

protocol HealthRepositoryProtocol {
    func fetchCoreData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws -> [T.HealthDataType]
    func syncData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async -> Result<[T.HealthDataType], Error>
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
        print("Une nouvelle tentative de synchronisation vient d'être initiée au \(startDate)")
        return try await healthKitSource.fetch(factory, from: startDate)
    }
    
    func mergeCoreDataWithHealthKitData<T: HealthDataFactoryProtocol>(_ factory: T.Type, localData: [T.CoreDataType], with healthKitData: [T.HealthDataType]) async throws -> [T.HealthDataType] {
        let newEntries = coreDataSource.mergeCoreDataWithHealthKitData(factory, localData: localData, with: healthKitData)
        try await coreDataSource.save()
        
        return factory.mapCoreDataToHealthKit(newEntries)
    }

    func syncData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async -> Result<[T.HealthDataType], Error> {
        let lastSync = await syncStorage.getLastSync(for: factory.id)
        print("Le last sync pour \(factory.id.description) est le \(lastSync ?? Date.distantPast)")

        guard syncStrategy.shouldSync(lastSync: lastSync) else {
            print("Pas de synchronisation nécessaire")
            return .success([])
        }

        do {
            let newItemsHealhKit = try await fetchHealthKit(factory, from: lastSync ?? .distantPast)
            guard !newItemsHealhKit.isEmpty else {
                print("Aucun nouvel élément récupéré depuis HealthKit pour \(factory.id)")
                return .success([])
            }
            
            let dataFetched = coreDataSource.getDataFetched(factory)
            let newItemsMerged = try await mergeCoreDataWithHealthKitData(factory, localData: dataFetched, with: newItemsHealhKit)
            
             await syncStorage.updateLastSync(for: factory.id)
             print("Le last sync pour \(factory.id.description) vient d'être saved")
            
            return .success(newItemsMerged)
        } catch {
            print("Erreur lors de la synchronisation : \(error)")
            return .failure(error)
        }
    }
}

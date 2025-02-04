//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import HealthKit
import CoreData

enum HealthError: Error {
    case syncFailed
    case fetchFailed
    case saveFailed
    case authorizationDenied
    case unsupportedDataType
    case invalidData
}

@MainActor
class HealthDashboardViewModel: ObservableObject {
    enum State {
        case initial
        case loading
        case loaded
        case error(Error)
    }
    
    @Published var healthMetrics = HealthMetrics()
    /*@Published*/ private(set) var state: State = .initial // TODO: Refaire le state
    
    private let repository: HealthRepositoryProtocol
    private let authorizationManager: HealthKitAuthorizationManager

    init(repository: HealthRepositoryProtocol, authorizationManager: HealthKitAuthorizationManager) {
        self.repository = repository
        self.authorizationManager = authorizationManager
    }
    
    func initialize() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.authorizationManager.requestAuthorization()
                await self.loadAndSyncData()
            } catch {
                self.state = .error(error)
            }
        }
    }
    
    private func loadAndSyncData() async {
        await loadAllLocalData()
        await syncAllHealthData()
    }
    
    private func loadAllLocalData() async {
        await withTaskGroup(of: Void.self) { group in
            for type in HealthMetricType.allCases {
                group.addTask {
                    await self.loadLocalData(type.healthKitFactory)
                }
            }
        }
    }
    
    private func loadLocalData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async {
        do {
            let localData = try await repository.fetchCoreData(factory)
            print("Data loaded \(factory.id.description)")
            
            await MainActor.run {
                healthMetrics.set(factory.id, items: localData)
                print("Data displayed \(factory.id.description)")
            }
            
        } catch {
            print("Failed to load data for \(factory.id.description): \(error)")
            await MainActor.run { state = .error(error) }
        }
    }
    
    private func syncAllHealthData() async {
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            while true {
                await withTaskGroup(of: Void.self) { group in
                    for type in HealthMetricType.allCases {
                        group.addTask {
                            await self.syncHealthData(type.healthKitFactory)
                        }
                    }
                }
                try? await Task.sleep(nanoseconds: AppConstants.TimeDelay.rateLimitSleep * 1_000_000_000)
            }
        }
    }
    
    private func syncHealthData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async {
        let result = await repository.syncData(factory)
        
        switch result {
        case .success(let updatedData):
            if (!updatedData.isEmpty) {
                await MainActor.run {
                    healthMetrics.set(factory.id, items: updatedData)
                }
            }
            
        case .failure(let error):
            print("Sync failed for \(factory.id.description): \(error)")
            await MainActor.run {
                self.state = .error(error)
            }
        }
    }
}

enum HealthDashboardFactory {
    @MainActor static func makeViewModel() -> HealthDashboardViewModel {
        let coreDataSource = CoreDataSource.shared
        let healthKitSource = HealthKitSource()
        let syncStrategy = TimeBasedSyncStrategy(minimumInterval: AppConstants.TimeDelay.syncRetryDelay)
        let lastSyncStorage = LastSyncStorage()
        
        let repository = HealthRepository(
            coreDataSource: coreDataSource,
            healthKitSource: healthKitSource,
            syncStrategy: syncStrategy,
            syncStorage: lastSyncStorage
        )
        
        let authorizationManager = HealthKitAuthorizationManager()
        
        return HealthDashboardViewModel(repository: repository, authorizationManager: authorizationManager)
    }
}

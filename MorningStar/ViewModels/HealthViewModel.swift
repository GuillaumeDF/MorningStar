//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import HealthKit
import CoreData
import Observation

@MainActor
@Observable
class HealthDashboardViewModel {
    enum State {
        case initial
        case loading
        case loaded
        case error(Error)
    }

    var healthMetrics = HealthMetrics()

    private let repository: HealthRepositoryProtocol
    private let authorizationManager: HealthKitAuthorizationManager
    private var syncTask: Task<Void, Never>?

    init(repository: HealthRepositoryProtocol, authorizationManager: HealthKitAuthorizationManager) {
        self.repository = repository
        self.authorizationManager = authorizationManager
    }

    deinit {
        syncTask?.cancel()
    }

    func stopSync() {
        syncTask?.cancel()
        syncTask = nil
    }

    func initialize() {
        Task { [weak self] in
            guard let self = self else { return }
            //repository.clearApp()
            do {
                try await self.authorizationManager.requestAuthorization()
                await self.loadAndSyncData()
            } catch {
                Logger.logError(error: error)
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
            Logger.logInfo(factory.id, message: "Successfully loaded local data from the repository.")

            healthMetrics.set(factory.id, items: localData)
            Logger.logInfo(factory.id, message: "Local data has been successfully displayed.")
        } catch {
            Logger.logError(factory.id, error: error)
        }
    }
    
    private func syncAllHealthData() async {
        syncTask?.cancel()

        syncTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { return }

                await withTaskGroup(of: Void.self) { group in
                    for type in HealthMetricType.allCases {
                        group.addTask {
                            await self.syncHealthData(type.healthKitFactory)
                        }
                    }
                }

                do {
                    try await Task.sleep(nanoseconds: AppConstants.Duration.rateLimitSleep * 1_000_000_000)
                } catch {
                    return
                }
            }
        }
    }
    
    private func syncHealthData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async {
        do {
            let updatedData = try await repository.syncData(factory)

            if !updatedData.isEmpty {
                healthMetrics.set(factory.id, items: updatedData)
            }
        } catch {
            Logger.logError(factory.id, error: error)
        }
    }
}

enum HealthDashboardFactory {
    @MainActor static func makeViewModel() -> HealthDashboardViewModel {
        let coreDataSource = CoreDataSource.shared
        let healthKitSource = HealthKitSource()
        let syncStrategy = TimeBasedSyncStrategy(minimumInterval: AppConstants.Duration.syncRetryDelay)
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

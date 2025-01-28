//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import HealthKit
import CoreData

// TODO: Verifier l'autorisation de heartRate
enum HealthDataType: CaseIterable, CustomStringConvertible {
    case steps
    case calories
    case weight
    case sleep
    case workouts
    //case heartRate
    
    var description: String {
        switch self {
        case .steps: return "steps"
        case .calories: return "calories"
        case .weight: return "weight"
        case .sleep: return "sleep"
        case .workouts: return "workouts"
            //case .heartRate: return "heartRate"
        }
    }
    
    var healthKitFactory: any HealthDataFactoryProtocol.Type {
        switch self {
        case .steps: return StepDataManagerFactory.self
        case .calories: return CalorieBurnedDataManagerFactory.self
        case .weight: return WeightDataManagerFactory.self
        case .sleep: return SleepDataManagerFactory.self
        case .workouts: return WorkoutDataManagerFactory.self
            //case .heartRate: return HeartRateDataManagerFactory.self // TODO: A vérifier
        }
    }
}

protocol HealthDataFactoryProtocol {
    associatedtype HealthKitDataType // TODO: Rename
    associatedtype CoreDataType: NSManagedObject
    
    static var healthKitSampleType: HKSampleType? { get }
    static var id: HealthDataType { get }
    static var predicateCoreData: NSPredicate? { get }
    
    static func createSampleQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<SampleQueryDescriptor<[HealthKitDataType]>>?
    static func createStatisticsQueryManager(for healthStore: HKHealthStore, from startDate: Date, to endDate: Date) -> HealthDataManager<StatisticsCollectionQueryDescriptor<[HealthKitDataType]>>?
    
    static func transformHealthKitToCoreData(_ healthKitData: [HealthKitDataType], context: NSManagedObjectContext)
    static func transformCoreDataToHealthKit(_ coreDataEntry: [CoreDataType]) -> [HealthKitDataType]
}

protocol HealthRepositoryProtocol {
    func fetchCoreData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws -> [T.HealthKitDataType]
    func syncData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async -> Result<[T.HealthKitDataType], Error>
}

// MARK: - Data Sources
protocol CoreDataSourceProtocol {
    func create<T: HealthDataFactoryProtocol>(_ factory: T.Type, items: [T.HealthKitDataType])
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, options: CoreDataSource.SortOrder) async throws -> [T.CoreDataType]
    func getFetchedRecords<T: HealthDataFactoryProtocol>(_ factory: T.Type) -> [T.CoreDataType]
    func save() async throws
}

protocol HealthKitSourceProtocol {
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date) async throws -> [T.HealthKitDataType]
}

enum HealthError: Error {
    case syncFailed
    case fetchFailed
    case saveFailed
    case authorizationDenied
    case unsupportedDataType
    case invalidData
}

// MARK: - Sync Strategy Protocol and Implementations

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

// MARK: - Last Sync Storage

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

class HealthKitAuthorizationManager {
    private let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }
    
    func requestAuthorization() async throws {
        let typesToRead: Set<HKSampleType> = Set(HealthDataType.allCases.compactMap { $0.healthKitFactory.healthKitSampleType })
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? HealthError.authorizationDenied)
                }
            }
        }
    }
}

// MARK: - CoreData Implementation
class CoreDataSource: CoreDataSourceProtocol {
    enum SortOrder {
        case dateAscending
        case dateDescending
    }
    
    static let shared = CoreDataSource()
    private(set) var persistentContainer: NSPersistentContainer
    private(set) var fetchedRecords: [HealthDataType: [NSManagedObject]] = [:]

    private init() {
        persistentContainer = NSPersistentContainer(name: "HealthDataModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        //self.deleteAllEntities()
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func getFetchedRecords<T: HealthDataFactoryProtocol>(_ factory: T.Type) -> [T.CoreDataType] {
        fetchedRecords[factory.id] as? [T.CoreDataType] ?? []
    }
    
    func create<T: HealthDataFactoryProtocol>(_ factory: T.Type, items: [T.HealthKitDataType]) { // TODO ajouter un throws avec gestion d'erreurs (CoreDataError)
        context.performAndWait {
            factory.transformHealthKitToCoreData(items, context: context)
        }
    }
    
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, options: SortOrder) throws -> [T.CoreDataType] {
        let entityName = String(describing: T.CoreDataType.self)
        let fetchRequest = NSFetchRequest<T.CoreDataType>(entityName: entityName)
        
        fetchRequest.predicate = factory.predicateCoreData

        switch options {
        case .dateAscending:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        case .dateDescending:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        }
        
        var results: [T.CoreDataType] = []
        var fetchError: Error?

        context.performAndWait {
            do {
                results = try context.fetch(fetchRequest)
                fetchedRecords[factory.id] = results
            } catch let error {
                fetchError = error
            }
        }

        if let error = fetchError {
            throw error
        }
        
        return results
    }
    
    func save() { // TODO: Remettre le save
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    private func deleteAllEntities() {
        let entities = persistentContainer.managedObjectModel.entities
        
        entities.forEach { entity in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
                print("Données supprimées pour \(entity.name!)")
            } catch {
                print("Erreur lors de la suppression de l'entité \(entity.name!): \(error)")
            }
        }
    }
}

// MARK: - HealthKit Implementation
class HealthKitSource: HealthKitSourceProtocol {
    private let healthStore: HKHealthStore
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
    }
    
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date) async throws -> [T.HealthKitDataType] {
       switch factory.id {
       case .workouts, .sleep, .weight:
           guard let manager = factory.createSampleQueryManager(
               for: healthStore,
               from: startDate,
               to: Date()
           ) else {
               throw HealthKitError.managerCreationFailed
           }
               
           return try await manager.fetchData()
           
       case .steps, .calories:
           guard let manager = factory.createStatisticsQueryManager(
               for: healthStore,
               from: startDate,
               to: Date()
           ) else {
               throw HealthKitError.managerCreationFailed
           }
               
           return try await manager.fetchData()
           
//       case .heartRate:
//           return []
       }
    }
}

// MARK: - Repository Implementation with Sync Coordination
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
    
    func fetchCoreData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws -> [T.HealthKitDataType] {
        let localData = try await coreDataSource.fetch(factory, options: .dateDescending)
        let healthData = factory.transformCoreDataToHealthKit(localData)
        
        return healthData
    }
    
    func fetchHealthKit<T: HealthDataFactoryProtocol>(
        _ factory: T.Type,
        from startDate: Date
    ) async throws -> [T.HealthKitDataType] {
        return try await healthKitSource.fetch(factory, from: startDate)
    }
    
    func saveData<T: HealthDataFactoryProtocol>(_ factory: T.Type, items: [T.HealthKitDataType]) async throws { // TODO: Faire le save des items
        coreDataSource.create(factory, items: items)
        print("Les données de \(factory.id.description) vient d'être créer dans CoreData")
        
        try await coreDataSource.save()
        print("Les données de \(factory.id.description) vient d'être saved dans CoreData")
    }

    //        let today = Date()
    //        let lastSync = Calendar.current.date(byAdding: .month, value: -1, to: today)
    func syncData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async -> Result<[T.HealthKitDataType], Error> {
        let lastSync = await syncStorage.getLastSync(for: factory.id)
        print("Le last sync pour \(factory.id.description) est le \(lastSync ?? Date.distantPast)")

        guard syncStrategy.shouldSync(lastSync: lastSync) else {
            print("Pas de synchronisation nécessaire")
            return .success([])
        }

        do {
            // Récupération des données HealthKit
            let newItems = try await fetchHealthKit(factory, from: lastSync ?? .distantPast)
            guard !newItems.isEmpty else {
                print("Aucun nouvel élément récupéré depuis HealthKit pour \(factory.id)")
                return .success([])
            }
            //let localDataFetched = coreDataSource.getFetchedRecords(factory)
            
            //let newItemsMerged = merger newItem and localDataFetched
            
            // Sauvegarde les données récupérées
            try await saveData(factory, items: newItems) // TODO: Remplace par newItemsMerged

            // Mise à jour du dernier temps de synchronisation
             await syncStorage.updateLastSync(for: factory.id)
             print("Le last sync pour \(factory.id.description) vient d'être saved")
            
            //let healthData = factory.transformCoreDataToHealthKit(localData)
            //return .success(healthData)
            
            return .success(newItems)
        } catch {
            print("Erreur lors de la synchronisation : \(error)")
            return .failure(error)
        }
    }
}

struct HealthMetrics {
    var stepCountHistory: [StepPeriod] = []
    var calorieBurnedHistory: [CaloriesPeriod] = []
    var weightHistory: [WeightPeriod] = []
    var sleepHistory: [SleepPeriod] = []
    var workoutHistory: [WeeklyWorkouts] = []
    
    mutating func set<T>(_ type: HealthDataType, items: [T]) {
        switch type {
        case .steps:
            stepCountHistory = items as? [StepPeriod] ?? []
        case .calories:
            calorieBurnedHistory = items as? [CaloriesPeriod] ?? []
        case .weight:
            weightHistory = items as? [WeightPeriod] ?? []
        case .sleep:
            sleepHistory = items as? [SleepPeriod] ?? []
        case .workouts:
            workoutHistory = items as? [WeeklyWorkouts] ?? []
        }
    }
}

@MainActor
class HealthDashboardViewModel: ObservableObject {
    // MARK: - Types
    
    enum State {
        case initial
        case loading
        case loaded
        case error(Error)
    }
    
    // MARK: - Properties
    
    @Published var healthMetrics = HealthMetrics()
    /*@Published*/ private(set) var state: State = .initial
    
    private let repository: HealthRepositoryProtocol
    private let authorizationManager: HealthKitAuthorizationManager
    
    // MARK: - Initialization
    
    init(repository: HealthRepositoryProtocol, authorizationManager: HealthKitAuthorizationManager) {
        self.repository = repository
        self.authorizationManager = authorizationManager
    }
    
    // MARK: - Public Methods
    
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
    
    // MARK: - Private Methods
    
    private func loadAndSyncData() async {
        await loadAllLocalData()
        await syncAllHealthData()
    }
    
    private func loadAllLocalData() async {
        await withTaskGroup(of: Void.self) { group in
            for type in HealthDataType.allCases {
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
                    for type in HealthDataType.allCases {
                        group.addTask {
                            await self.syncHealthData(type.healthKitFactory)
                        }
                    }
                }
                try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
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

// MARK: - Factory

enum HealthDashboardFactory {
    @MainActor static func makeViewModel() -> HealthDashboardViewModel {
        let coreDataSource = CoreDataSource.shared
        let healthKitSource = HealthKitSource()
        let syncStrategy = TimeBasedSyncStrategy(minimumInterval: 3600)
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

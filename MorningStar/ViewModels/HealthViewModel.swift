//
//  HealthViewModel.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 01/09/2024.
//

import HealthKit
import CoreData

enum HealthDataType: CaseIterable, CustomStringConvertible {
    case steps
    case calories
    case weight
    case sleep
    case workouts
    case heartRate
    
    var description: String {
        switch self {
        case .steps: return "steps"
        case .calories: return "calories"
        case .weight: return "weight"
        case .sleep: return "sleep"
        case .workouts: return "workouts"
        case .heartRate: return "heartRate"
        }
    }
    
    var healthKitFactory: any HealthDataFactoryProtocol.Type {
        switch self {
        case .steps: return StepDataManagerFactory.self
        case .calories: return CalorieBurnedDataManagerFactory.self
        case .weight: return WeightDataManagerFactory.self
        case .sleep: return SleepDataManagerFactory.self
        case .workouts: return WorkoutDataManagerFactory.self
        case .heartRate: return HeartRateDataManagerFactory.self // TODO: A vérifier
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
    func fetchHealthKit<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date, completion: @escaping (Result<[T.HealthKitDataType], Error>) -> Void)
    func saveData<T: HealthDataFactoryProtocol>(_ factory: T.Type, items: [T.HealthKitDataType]) async throws
    func syncData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws
}

// MARK: - Data Sources
protocol CoreDataSourceProtocol {
    func create<T: HealthDataFactoryProtocol>(_ factory: T.Type, items: [T.HealthKitDataType])
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, options: CoreDataSource.SortOrder) async throws -> [T.CoreDataType]
    func save() async throws
}

protocol HealthKitSourceProtocol {
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date, completion: @escaping (Result<[T.HealthKitDataType], Error>) -> Void)
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
    
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date, completion: @escaping (Result<[T.HealthKitDataType], Error>) -> Void) {
        switch factory.id {
        case .workouts, .sleep, .weight:
            let manager = factory.createSampleQueryManager(for: healthStore, from: startDate, to: Date())
            
            manager?.fetchData { result in
                completion(result)
            }
        case .steps, .calories:
            let manager = factory.createStatisticsQueryManager(for: healthStore, from: startDate, to: Date())
            
            manager?.fetchData { result in
                completion(result)
            }
        case .heartRate:
            return
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
        let healthData = factory.transformCoreDataToHealthKit(localData) // TODO: Rename
        
        return healthData
    }
    
    func fetchHealthKit<T: HealthDataFactoryProtocol>(_ factory: T.Type, from startDate: Date, completion: @escaping (Result<[T.HealthKitDataType], Error>) -> Void) {
        healthKitSource.fetch(factory, from: startDate) { result in
            completion(result)
        }
    }
    
    func saveData<T: HealthDataFactoryProtocol>(_ factory: T.Type, items: [T.HealthKitDataType]) async throws { // TODO: Faire le save des items
        coreDataSource.create(factory, items: items)
        print("Les données de \(factory.id.description) vient d'être créer dans CoreData")
        
        try await coreDataSource.save()
        print("Les données de \(factory.id.description) vient d'être saved dans CoreData")
    }

    func syncData<T: HealthDataFactoryProtocol>(_ factory: T.Type) async throws {
        let lastSync = await syncStorage.getLastSync(for: factory.id)
        print("Le last sync pour \(factory.id.description) est le \(lastSync ?? Date.distantPast)")
//        let today = Date()
//        let lastSync = Calendar.current.date(byAdding: .month, value: -1, to: today)

        guard syncStrategy.shouldSync(lastSync: lastSync) else {
            print("Pas de synchronisation nécessaire")
            return
        }

        try await withCheckedThrowingContinuation { continuation in
            fetchHealthKit(factory, from: lastSync ?? .distantPast) { [weak self] result in
                switch result {
                case .success(let items):
                    Task {
                        do {
                            try await self?.saveData(factory, items: items)
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: HealthError.syncFailed)
                        }
                    }
                case .failure:
                    continuation.resume(throwing: HealthError.syncFailed)
                }
            }
        }

        //await syncStorage.updateLastSync(for: factory.id)
        //print("Le last sync pour \(factory.id.description) vient d'être saved")
    }
}

//class HealthMetrics: ObservableObject {
//    @Published private var data: [HealthDataType: [Any]] = [:]
//
//    // Getter générique
//    func get<T>(_ type: HealthDataType) -> [T]? {
//        return data[type] as? [T]
//    }
//
//    // Setter générique (déclenche automatiquement SwiftUI)
//    func set<T>(_ type: HealthDataType, items: [T]) {
//        data[type] = items
//    }
//}

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
        default:
            break
        }
    }
}
// MARK: - View Model Implementation
@MainActor
class HealthDashboardViewModel: ObservableObject {
    enum State {
        case initial
        case loading
        case loaded
        case error(Error)
    }
    
    @Published var healthMetrics = HealthMetrics()
    /*@Published*/ var state: State = .initial
    
    private let repository: HealthRepositoryProtocol
    private let authorizationManager: HealthKitAuthorizationManager
    
    init(repository: HealthRepositoryProtocol, authorizationManager: HealthKitAuthorizationManager) {
        self.repository = repository
        self.authorizationManager = authorizationManager
    }
    
    func initialize() {
        print("Initializing HealthDashboardViewModel...")
        Task { [weak self] in
            guard let self = self else { return }
            do {
                self.state = .loading
                try await self.authorizationManager.requestAuthorization()
                await self.loadData()
            } catch {
                self.state = .error(error)
            }
        }
    }
    
    func loadData() async {
        self.state = .loading
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for type in HealthDataType.allCases {
                    group.addTask {
                        let data = try await self.repository.fetchCoreData(type.healthKitFactory)
                        print("Les données de \(type.description) vient d'être fetch de CoreData")
                        
                        await MainActor.run {
                            self.healthMetrics.set(type, items: data)
                            print("Les données de \(type.description) vient d'être set pour être affichées")
                        }
                    }
                }
                
                try await group.waitForAll()
            }
            state = .loaded
            
            //await syncData()
        } catch {
            state = .error(error)
        }
    }
    
    private func syncData() async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for type in HealthDataType.allCases {
                    group.addTask {
                        try await self.repository.syncData(type.healthKitFactory)
                    }
                }

                try await group.waitForAll()
            }
            
            // Reload data after successful sync // Remettre la recusivité loadData avec la syncStrategy
            //await loadData()
        } catch {
            state = .error(error)
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

//
//  CoreDataManager.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 27/10/2024.
//

import CoreData
import Foundation

//// MARK: - Error Handling
//enum CoreDataError: LocalizedError {
//    case failedToSaveContext(Error)
//    case failedToFetchData(Error)
//    case failedToDeleteData(Error)
//    case entityNotFound(String)
//    case invalidModelName(String)
//    case failedToInitialize(Error)
//    
//    var errorDescription: String? {
//        switch self {
//        case .failedToSaveContext(let error):
//            return "Failed to save context: \(error.localizedDescription)"
//        case .failedToFetchData(let error):
//            return "Failed to fetch data: \(error.localizedDescription)"
//        case .failedToDeleteData(let error):
//            return "Failed to delete data: \(error.localizedDescription)"
//        case .entityNotFound(let entityName):
//            return "Entity not found: \(entityName)"
//        case .invalidModelName(let name):
//            return "Invalid model name: \(name)"
//        case .failedToInitialize(let error):
//            return "Failed to initialize CoreData stack: \(error.localizedDescription)"
//        }
//    }
//}
//
//// MARK: - Protocols
//protocol CoreDataManaging { // TODO: Changer le nom du protocol
//    func create<T: HealthDataFactoryProtocol>(_ factory: T.Type, items: [T.HealthKitDataType]) -> [T.CoreDataType]
//    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [T.CoreDataType]
//    func save() async throws
//}
//
//// MARK: - Configuration
//struct CoreDataConfiguration {
//    let modelName: String
//    let storeType: String
//    let bundleIdentifier: String
//    let shouldMigrateStore: Bool
//    let shouldMergeChangesFromParent: Bool
//    
//    static let `default` = CoreDataConfiguration(
//        modelName: "HealthDataModel",
//        storeType: NSSQLiteStoreType,
//        bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
//        shouldMigrateStore: true,
//        shouldMergeChangesFromParent: true
//    )
//}
//
//// MARK: - CoreDataManager
//final class CoreDataManager: CoreDataManaging {
//    
//    static let shared = CoreDataManager()
//    
//    // MARK: - Properties
//    private let configuration: CoreDataConfiguration
//    
//    private(set) lazy var mainContext: NSManagedObjectContext = {
//        let context = persistentContainer.viewContext
//        context.automaticallyMergesChangesFromParent = configuration.shouldMergeChangesFromParent
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return context
//    }()
//    
//    private(set) lazy var backgroundContext: NSManagedObjectContext = {
//        let context = persistentContainer.newBackgroundContext()
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return context
//    }()
//    
//    private lazy var persistentContainer: NSPersistentContainer = {
//        guard let modelURL = Bundle(identifier: configuration.bundleIdentifier)?
//                .url(forResource: configuration.modelName, withExtension: "momd"),
//              let model = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("Failed to load Core Data model")
//        }
//        
//        let container = NSPersistentContainer(name: configuration.modelName, managedObjectModel: model)
//        
//        if let description = container.persistentStoreDescriptions.first {
//            description.type = configuration.storeType
//            description.shouldMigrateStoreAutomatically = configuration.shouldMigrateStore
//            description.shouldInferMappingModelAutomatically = configuration.shouldMigrateStore
//        }
//        
//        var loadError: Error?
//        container.loadPersistentStores { _, error in
//            loadError = error
//        }
//        
//        if let error = loadError {
//            fatalError("Failed to load persistent stores: \(error)")
//        }
//        
//        return container
//    }()
//    
//    // MARK: - Initialization
//    init(configuration: CoreDataConfiguration = .default) {
//        self.configuration = configuration
//    }
//    
//    // MARK: - CRUD Operations
//    func create<T: HealthDataFactoryProtocol>(_ factory: T.Type, items: [T.HealthKitDataType]) -> [T.CoreDataType] {
//        let context = mainContext
//        let entities = factory.transformHealthKitToCoreData(items, context: context)
//        
//        return entities
//    }
//    
//    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [T.CoreDataType] {
//        let context = backgroundContext
//        guard let fetchRequest = T.CoreDataType.fetchRequest() as? NSFetchRequest<T.CoreDataType> else { // ou sinon EntityName
//            //throw CoreDataError.invalidFetchRequest
//            throw CoreDataError.entityNotFound("")
//        }
//        
//        fetchRequest.predicate = predicate
//        fetchRequest.sortDescriptors = sortDescriptors
//        
//        do {
//            let periodEntries = try context.fetch(fetchRequest)
//            return periodEntries
//        } catch {
//            throw CoreDataError.failedToFetchData(error)
//        }
//    }
//    
//    func save() async throws {
////        let context = mainContext
////        
////        guard context.hasChanges else { return }
////        
////        try await context.perform {
////            do {
////                try context.save()
////            } catch {
////                throw CoreDataError.failedToSaveContext(error)
////            }
////        }
//    }
//}

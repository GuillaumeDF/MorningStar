//
//  CoreDataSource.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 04/02/2025.
//

import Foundation
import CoreData

protocol CoreDataSourceProtocol {
    func fetch<T: HealthDataFactoryProtocol>(_ factory: T.Type, options: CoreDataSource.SortOrder) async throws -> [T.CoreDataType]
    func getDataFetched<T: HealthDataFactoryProtocol>(_ factory: T.Type) throws -> [T.CoreDataType]
    func getMostRecentDate<T: HealthDataFactoryProtocol>(_ factory: T.Type) throws -> Date
    func mergeCoreDataWithHealthKitData<T: HealthDataFactoryProtocol>(_ factory: T.Type, localData: [T.CoreDataType], with healthKitData: [T.HealthDataType]) -> [T.CoreDataType]
    func save() throws
}

class CoreDataSource: CoreDataSourceProtocol {
    enum SortOrder {
        case dateAscending
        case dateDescending
    }
    
    static let shared = CoreDataSource()
    private(set) var persistentContainer: NSPersistentContainer
    private(set) var fetchHistory: [HealthMetricType: [NSManagedObject]] = [:]

    private init() {
        persistentContainer = NSPersistentContainer(name: "HealthDataModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func getDataFetched<T: HealthDataFactoryProtocol>(_ factory: T.Type) throws -> [T.CoreDataType] {
        guard let dataFetched = fetchHistory[factory.id] as? [T.CoreDataType] else {
            throw CoreDataError.unsupportedDataType
        }
        
        return dataFetched
    }
    
    func getMostRecentDate<T: HealthDataFactoryProtocol>(_ factory: T.Type) throws -> Date {
        let entityName = String(describing: T.CoreDataType.self)
        let fetchRequest = NSFetchRequest<T.CoreDataType>(entityName: entityName)

        fetchRequest.predicate = factory.predicateCoreData
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        fetchRequest.fetchLimit = 1

        let results = try context.fetch(fetchRequest)
        guard let firstObject = results.first,
              let firstDate = firstObject.value(forKey: "endDate") as? Date else {
            return .distantPast
        }

        return firstDate.localTime
    }

    
    func mergeCoreDataWithHealthKitData<T: HealthDataFactoryProtocol>(_ factory: T.Type, localData: [T.CoreDataType], with healthKitData: [T.HealthDataType]) -> [T.CoreDataType] {
        context.performAndWait {
           return factory.mergeCoreDataWithHealthKitData(localData, with: healthKitData, in: context)
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
                fetchHistory[factory.id] = results
            } catch let error {
                fetchError = error
            }
        }

        if let error = fetchError {
            throw error
        }
        
        return results
    }
    
    func save() throws {
        var saveError: Error?
        
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    saveError = error
                }
            }
        }
        
        if let error = saveError {
            throw error
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

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
    func getDataFetched<T: HealthDataFactoryProtocol>(_ factory: T.Type) -> [T.CoreDataType]
    func mergeCoreDataWithHealthKitData<T: HealthDataFactoryProtocol>(_ factory: T.Type, localData: [T.CoreDataType], with healthKitData: [T.HealthKitDataType]) -> [T.CoreDataType]
    func save() async throws
}

class CoreDataSource: CoreDataSourceProtocol {
    enum SortOrder {
        case dateAscending
        case dateDescending
    }
    
    static let shared = CoreDataSource()
    private(set) var persistentContainer: NSPersistentContainer
    private(set) var fetchHistory: [HealthDataType: [NSManagedObject]] = [:]

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
    
    func getDataFetched<T: HealthDataFactoryProtocol>(_ factory: T.Type) -> [T.CoreDataType] {
        fetchHistory[factory.id] as? [T.CoreDataType] ?? []
    }
    
    func mergeCoreDataWithHealthKitData<T: HealthDataFactoryProtocol>(_ factory: T.Type, localData: [T.CoreDataType], with healthKitData: [T.HealthKitDataType]) -> [T.CoreDataType] {
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
    
    func save() {
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

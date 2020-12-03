//
//  CoreDataHelper.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 03.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import Foundation
import CoreData

func setupMemoryManagedObjectContext() -> NSManagedObjectContext {

    guard let modelURL = Bundle.main.url(forResource: "Chat", withExtension: "momd") else {
        fatalError("model not found")
    }
    
    guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
        fatalError("managedObjectModel couldn't be created")
    }
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                          configurationName: nil,
                                                          at: nil,
                                                          options: nil)
    } catch {
        fatalError(error.localizedDescription)
    }
    
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    managedObjectContext.mergePolicy = NSOverwriteMergePolicy

    return managedObjectContext
}

public extension NSManagedObject {
    convenience init?(using context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else { return nil }
        self.init(entity: entity, insertInto: context)
    }
}

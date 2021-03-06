//
//  CoreDataStack.swift
//  ChatApp
//
//  Created by Наталья Мирная on 26.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData

protocol PersistantProtocol {
    var didUpdateDataBase: ((PersistantProtocol) -> Void)? { get }
    var mainContext: NSManagedObjectContext { get }
    
    func performSave(_ handler: @escaping (NSManagedObjectContext) -> Void)
}

class CoreDataStack: PersistantProtocol {
    
    private var logger: LoggerVerboseLevel
    
    var didUpdateDataBase: ((PersistantProtocol) -> Void)?
    
    init(logger: LoggerVerboseLevel) {
        self.logger = logger
        configure()
    }
    
    private var storeURL: URL = {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory,
                                                          in: .userDomainMask).last
            else {
                fatalError("documentPath not found")
        }
        return documentsUrl.appendingPathComponent("Chat.sqlite")
    }()
    
    private let dataNameModel = "Chat"
    private let dataModelExtension = "momd"
    
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.dataNameModel,
                                             withExtension: self.dataModelExtension)
            else {
                fatalError("model not found")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("managedObjectModel couldn't be created")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: storeURL,
                                               options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return coordinator
    }()
    
    private lazy var writterContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = writterContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()
    
    private func saveContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func performSave(_ handler: @escaping (NSManagedObjectContext) -> Void) {
        let context = saveContext()
        context.performAndWait { [weak self] in
            handler(context)
            if context.hasChanges {
                do {
                    try context.obtainPermanentIDs(for: Array(context.insertedObjects))
                } catch {
                    assertionFailure(error.localizedDescription)
                }
                self?.performSave(in: context)
            }
        }
    }
    
    private func performSave(in context: NSManagedObjectContext) {
        /*
         если контексты без PSC сохранять в perform,
         то для первого сообщения в printStatFromDatabase отображается в два раза больше каналов
         при этом, в самой бд данных ровно столько, сколько нужно и они не дублируются
         во втором сообщении кол-во каналов залогировано уже верно
         возможно это связано с тем, что на экране с каналами мы всегда пересохраняем все каналы в CoreData
         выглядит это так
         
         Добавлено объектов: 30
         В базе данных содержится 60 чатов
         Добавлено объектов: 30
         В базе данных содержится 30 чатов
         */
        if context === writterContext {
            context.perform {
                do { try context.save() } catch { assertionFailure(error.localizedDescription) }
            }
        } else {
            context.performAndWait {
                do { try context.save() } catch { assertionFailure(error.localizedDescription) }
            }
        }
        
        if let parent = context.parent { performSave(in: parent) }
    }
    
    private func enableObservers() {
        let notification = NotificationCenter.default
        notification.addObserver(self,
                                 selector: #selector(managedObjectContextObjectsDidChange(notification:)),
                                 name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                 object: mainContext)
    }
    
    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        didUpdateDataBase?(self)
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print("Добавлено объектов: \(inserts.count)")
            inserts.forEach {
                print(($0 as? NSManagedObjectDescriptionProtocol)?.description ?? "")
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("Обновлено объектов: \(updates.count)")
            updates.forEach {
                print(($0 as? NSManagedObjectDescriptionProtocol)?.description ?? "")
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("Удалено объектов: \(deletes.count)")
            deletes.forEach {
                print(($0 as? NSManagedObjectDescriptionProtocol)?.description ?? "")
            }
        }
    }
    
    private func printStatFromDatabase() {
        mainContext.perform {
            do {
                let count = try self.mainContext.count(for: ChannelDB.fetchRequest())
                print("В базе данных содержится \(count) чатов")
                let array = try self.mainContext.fetch(ChannelDB.fetchRequest()) as? [ChannelDB] ?? []
                array.forEach {
                    print($0.about)
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func configure() {
        // Для вывода полного состояния бд после каждого сохранения
        // нужно запустить схему ChatAppInfo
        if logger.verboseLevel == .info {
            didUpdateDataBase = { stack in
                guard let stack = stack as? CoreDataStack else { return }
                stack.printStatFromDatabase()
            }
        }
        enableObservers()
    }
}

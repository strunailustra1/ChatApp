//
//  PersistantMock.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 03.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import Foundation
import CoreData

class PersistantMock: PersistantProtocol {
    
    var didUpdateDataBase: ((PersistantProtocol) -> Void)?
    
    var mainContext: NSManagedObjectContext
    
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    
    func performSave(_ handler: @escaping (NSManagedObjectContext) -> Void) {
        mainContext.performAndWait {
            handler(mainContext)
            if mainContext.hasChanges {
                do { try mainContext.save() } catch { assertionFailure(error.localizedDescription) }
            }
        }
    }
}

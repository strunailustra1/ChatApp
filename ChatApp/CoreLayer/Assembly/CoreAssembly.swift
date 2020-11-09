//
//  CoreAssembly.swift
//  ChatApp
//
//  Created by Наталья Мирная on 09.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol CoreAssemblyProtocol {
    var coreDataStack: CoreDataStack { get } //todo protocol
    var firestoreDataProvider: FirestoreDataProvider { get } //todo protocol
    var gcdDataManager: ProfileDataManagerProtocol { get }
    var operationDataManager: ProfileDataManagerProtocol { get }
}

class CoreAssembly: CoreAssemblyProtocol {
    lazy var coreDataStack: CoreDataStack = CoreDataStack()
    lazy var firestoreDataProvider: FirestoreDataProvider = FirestoreDataProvider()
    lazy var gcdDataManager: ProfileDataManagerProtocol = GCDDataManager()
    lazy var operationDataManager: ProfileDataManagerProtocol = OperationDataManager()
}

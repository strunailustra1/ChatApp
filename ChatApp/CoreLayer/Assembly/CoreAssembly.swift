//
//  CoreAssembly.swift
//  ChatApp
//
//  Created by Наталья Мирная on 09.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol CoreAssemblyProtocol {
    var persistant: PersistantProtocol { get }
    var apiDataProvider: APIDataProviderProtocol { get }
    var gcdDataManager: ProfileDataManagerProtocol { get }
    var operationDataManager: ProfileDataManagerProtocol { get }
}

class CoreAssembly: CoreAssemblyProtocol {
    lazy var persistant: PersistantProtocol = CoreDataStack(logger: logger)
    lazy var apiDataProvider: APIDataProviderProtocol = FirestoreDataProvider()
    lazy var gcdDataManager: ProfileDataManagerProtocol = GCDDataManager()
    lazy var operationDataManager: ProfileDataManagerProtocol = OperationDataManager()
    
    private var logger: LoggerVerboseLevel
    
    init(logger: LoggerVerboseLevel) {
        self.logger = logger
    }
}

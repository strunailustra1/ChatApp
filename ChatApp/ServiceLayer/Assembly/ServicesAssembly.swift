//
//  ServicesAssembly.swift
//  ChatApp
//
//  Created by Наталья Мирная on 09.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol ServicesAssemblyProtocol {
    //todo protocols for everywhere
    var themesManager: ThemesManagerProtocol & ThemesPickerDelegate & ThemesPickerHandler { get }
    var messageRepository: MessageRepository { get }
    var channelRepository: ChannelRepository { get }
    var channelAPIManager: ChannelAPIManager { get }
    var messageAPIManager: MessageAPIManager { get }
    var imageComparator: ImageCompare { get }
    var profileRepository: ProfileRepository { get }
    //todo profileDataManager
}

class ServicesAssembly: ServicesAssemblyProtocol {
    
    private let coreAssembly: CoreAssemblyProtocol
    
    init(coreAssembly: CoreAssemblyProtocol) {
        self.coreAssembly = coreAssembly
    }
    
    lazy var themesManager: ThemesManagerProtocol & ThemesPickerDelegate & ThemesPickerHandler = ThemesManager()
    
    lazy var messageRepository: MessageRepository = MessageRepository(
        coreDataStack: coreAssembly.coreDataStack,
        channelRepository: channelRepository
    )
    
    lazy var channelRepository: ChannelRepository = ChannelRepository(
        coreDataStack: coreAssembly.coreDataStack
    )
    
    lazy var channelAPIManager: ChannelAPIManager = ChannelAPIManager(
        channelRepository: channelRepository,
        firestoreDataProvider: coreAssembly.firestoreDataProvider
    )
    
    lazy var messageAPIManager: MessageAPIManager = MessageAPIManager(
        messageRepository: messageRepository,
        firestoreDataProvider: coreAssembly.firestoreDataProvider
    )
    
    lazy var imageComparator: ImageCompare = ImageComparator()
    
    lazy var profileRepository: ProfileRepository = ProfileRepository(
        gcdDataManager: coreAssembly.gcdDataManager,
        operationDataManager: coreAssembly.operationDataManager
    )
}

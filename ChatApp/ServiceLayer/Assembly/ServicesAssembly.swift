//
//  ServicesAssembly.swift
//  ChatApp
//
//  Created by Наталья Мирная on 09.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol ServicesAssemblyProtocol {
    var themesManager: ThemesManagerProtocol & ThemesPickerDelegate & ThemesPickerHandler { get }
    var messageRepository: MessageRepositoryProtocol { get }
    var channelRepository: ChannelRepositoryProtocol { get }
    var channelAPIManager: ChannelAPIManagerProtocol { get }
    var messageAPIManager: MessageAPIManagerProtocol { get }
    var imageComparator: ImageComparatorProtocol { get }
    var profileRepository: ProfileRepositoryProtocol { get }
}

class ServicesAssembly: ServicesAssemblyProtocol {
    
    private let coreAssembly: CoreAssemblyProtocol
    
    init(coreAssembly: CoreAssemblyProtocol) {
        self.coreAssembly = coreAssembly
    }
    
    lazy var themesManager: ThemesManagerProtocol & ThemesPickerDelegate & ThemesPickerHandler = ThemesManager()
    
    lazy var messageRepository: MessageRepositoryProtocol = MessageRepository(
        persistant: coreAssembly.persistant,
        channelRepository: channelRepository
    )
    
    lazy var channelRepository: ChannelRepositoryProtocol = ChannelRepository(
        persistant: coreAssembly.persistant
    )
    
    lazy var channelAPIManager: ChannelAPIManagerProtocol = ChannelAPIManager(
        channelRepository: channelRepository,
        apiDataProvider: coreAssembly.apiDataProvider
    )
    
    lazy var messageAPIManager: MessageAPIManagerProtocol = MessageAPIManager(
        messageRepository: messageRepository,
        apiDataProvider: coreAssembly.apiDataProvider
    )
    
    lazy var imageComparator: ImageComparatorProtocol = ImageComparator()
    
    lazy var profileRepository: ProfileRepositoryProtocol = ProfileRepository(
        gcdDataManager: coreAssembly.gcdDataManager,
        operationDataManager: coreAssembly.operationDataManager
    )
}

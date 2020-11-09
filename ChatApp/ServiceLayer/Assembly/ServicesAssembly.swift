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
    var logger: Logger { get }
    var themesManager: ThemesManagerProtocol & ThemesPickerDelegate & ThemesPickerHandler { get }
    var messageRepository: MessageRepository { get }
    var channelRepository: ChannelRepository { get }
    //todo profileDataManager
    //todo firebase
}

class ServicesAssembly: ServicesAssemblyProtocol {
    
    private let coreAssembly: CoreAssemblyProtocol
    
    init(coreAssembly: CoreAssemblyProtocol) {
        self.coreAssembly = coreAssembly
    }
    
    lazy var logger: Logger = Logger()
    
    lazy var themesManager: ThemesManagerProtocol & ThemesPickerDelegate & ThemesPickerHandler = ThemesManager()
    
    lazy var messageRepository: MessageRepository = MessageRepository(
        coreDataStack: coreAssembly.coreDataStack,
        channelRepository: channelRepository
    )
    
    lazy var channelRepository: ChannelRepository = ChannelRepository(
        coreDataStack: coreAssembly.coreDataStack
    )
}

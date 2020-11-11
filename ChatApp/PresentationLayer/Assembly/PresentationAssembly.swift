//
//  PresentationAssembly.swift
//  ChatApp
//
//  Created by Наталья Мирная on 09.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol PresentationAssemblyProtocol {
    func conversationsListNavigationController() -> ConversationsListNavigationController
    func conversationViewController() -> ConversationViewController
    func profileViewController() -> ProfileViewController?
    func themesViewController() -> ThemesViewController?
}

class PresentationAssembly: PresentationAssemblyProtocol {
    private let serviceAssembly: ServicesAssemblyProtocol
    
    init(serviceAssembly: ServicesAssemblyProtocol) {
        self.serviceAssembly = serviceAssembly
    }
    
    func conversationsListNavigationController() -> ConversationsListNavigationController {
        // Устанавливаем тему на старте приложения
        serviceAssembly.themesManager.applyCurrentTheme()
        
        let rootVC = ConversationsListViewController(
            channelRepository: serviceAssembly.channelRepository,
            presentationAssembly: self,
            themesManager: serviceAssembly.themesManager,
            channelAPIManager: serviceAssembly.channelAPIManager,
            frcDelegate: ConversationsListFRCDelegate(),
            tableViewDataSourceDelegate: ConversationsListDataSourceDelegate(),
            profileRepository: serviceAssembly.profileRepository
        )
        
        // Загружаем профиль и обновляем фото в navigation bar
        serviceAssembly.profileRepository.loadFromStorage { _ in
            rootVC.updateNavigationRightButtonImage()
        }
        
        let nav = ConversationsListNavigationController(rootViewController: rootVC)
        nav.themesManager = serviceAssembly.themesManager
        
        return nav
    }
    
    func conversationViewController() -> ConversationViewController {
        return ConversationViewController(
            messageRepository: serviceAssembly.messageRepository,
            themesManager: serviceAssembly.themesManager,
            profileRepository: serviceAssembly.profileRepository,
            messageAPIManager: serviceAssembly.messageAPIManager,
            frcDelegate: ConversationFRCDelegate(),
            tableViewDataSourceDelegate: ConversationTableViewDataSourceDelegate()
        )
    }
    
    func profileViewController() -> ProfileViewController? {
        return ProfileViewController.storyboardInstance(
            themesManager: serviceAssembly.themesManager,
            imageComparator: serviceAssembly.imageComparator,
            profileRepository: serviceAssembly.profileRepository
        )
    }
    
    func themesViewController() -> ThemesViewController? {
        let themesVC = ThemesViewController.storyboardInstance(
            themesManager: serviceAssembly.themesManager,
            delegate: serviceAssembly.themesManager,
            themeChangeHandler: serviceAssembly.themesManager.themeChangeHandler
        )
        return themesVC
    }
}

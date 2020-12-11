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
    func imageCollectionViewController() -> ImageCollectionViewController
}

class PresentationAssembly: PresentationAssemblyProtocol {
    private let serviceAssembly: ServicesAssemblyProtocol
    
    private lazy var router: RouterProtocol = Router(presentationAssembly: self)
    
    private var emblemEmitter: EmblemEmitter?
    
    init(serviceAssembly: ServicesAssemblyProtocol) {
        self.serviceAssembly = serviceAssembly
    }
    
    func conversationsListNavigationController() -> ConversationsListNavigationController {
        // Устанавливаем тему на старте приложения
        serviceAssembly.themesManager.applyCurrentTheme()
        
        let rootVC = ConversationsListViewController(
            router: router,
            channelRepository: serviceAssembly.channelRepository,
            themesManager: serviceAssembly.themesManager,
            channelAPIManager: serviceAssembly.channelAPIManager,
            frcDelegate: ConversationsListFRCDelegate(),
            tableViewDataSourceDelegate: ConversationsListDataSourceDelegate(),
            profileRepository: serviceAssembly.profileRepository
        )
        
        // Загружаем профиль и обновляем фото в navigation bar
        let storageType: ProfileStorageType = Bool.random()
            ? ProfileStorageType.gcd
            : ProfileStorageType.operation
        
        serviceAssembly.profileRepository.loadFromStorage(by: storageType) { _ in
            rootVC.updateNavigationRightButtonImage()
        }
        
        let nav = ConversationsListNavigationController(rootViewController: rootVC)
        nav.themesManager = serviceAssembly.themesManager
        
        emblemEmitter = EmblemEmitter(view: nav.view)
        
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
        return ProfileViewController.storyboardInstance(settings: ProfileViewControllerSettings(
            themesManager: serviceAssembly.themesManager,
            imageComparator: serviceAssembly.imageComparator,
            profileRepository: serviceAssembly.profileRepository,
            profileTextFieldDelegate: ProfileTextFieldDelegate(),
            profileTextViewDelegate: ProfileTextViewDelegate(),
            router: router
        ))
    }
    
    func themesViewController() -> ThemesViewController? {
        let themesVC = ThemesViewController.storyboardInstance(
            themesManager: serviceAssembly.themesManager,
            delegate: serviceAssembly.themesManager,
            themeChangeHandler: serviceAssembly.themesManager.themeChangeHandler
        )
        return themesVC
    }
    
    func imageCollectionViewController() -> ImageCollectionViewController {
        let model = imageCollectionModel()
        
        let controller = ImageCollectionViewController(
            model: model,
            themesManager: serviceAssembly.themesManager,
            pixabayService: serviceAssembly.pixabayService,
            collectionViewDataSourceDelegate: ImageCollectionViewDataSourceDelegate()
        )
        
        model.delegate = controller
        
        return controller
    }
    
    private func imageCollectionModel() -> ImageCollectionModelProtocol {
        return ImageCollectionModel(pixabayService: serviceAssembly.pixabayService)
    }
}

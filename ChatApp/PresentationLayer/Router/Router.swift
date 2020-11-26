//
//  Router.swift
//  ChatApp
//
//  Created by Наталья Мирная on 26.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

protocol RouterProtocol {
    func presentConversationVC(in navigationController: UINavigationController, channel: Channel)
    func presentThemeVC(in navigationController: UINavigationController)
    func presentProfileVC(modalFrom controller: UIViewController, closeHandler: (() -> Void)?)
    func presentImageVC(modalFrom controller: UIViewController,
                        changeProfilePhotoDelegate: ChangeProfilePhotoDelegate?)
}

class Router: RouterProtocol {
    
    private let presentationAssembly: PresentationAssemblyProtocol
    
    private var emblemEmitter: EmblemEmitter?
    
    private lazy var transitionDelegate = AnimationTransitionDelegate()

    init(presentationAssembly: PresentationAssemblyProtocol) {
        self.presentationAssembly = presentationAssembly
    }
    
    func presentConversationVC(in navigationController: UINavigationController, channel: Channel) {
        let conversationVC = presentationAssembly.conversationViewController()
        conversationVC.channel = channel
        navigationController.pushViewController(conversationVC, animated: true)
    }
    
    func presentThemeVC(in navigationController: UINavigationController) {
        guard let themesVC = presentationAssembly.themesViewController() else { return }
        navigationController.pushViewController(themesVC, animated: true)
    }
    
    func presentProfileVC(modalFrom controller: UIViewController, closeHandler: (() -> Void)? = nil) {
        guard let profileVC = presentationAssembly.profileViewController() else { return }
        profileVC.closeHandler = closeHandler
        
        let navVC = UINavigationController(rootViewController: profileVC)
        navVC.transitioningDelegate = transitionDelegate
        navVC.modalPresentationStyle = .popover
        
        emblemEmitter = EmblemEmitter(view: navVC.view)
        
        controller.present(navVC, animated: true, completion: nil)
    }
    
    func presentImageVC(modalFrom controller: UIViewController,
                        changeProfilePhotoDelegate: ChangeProfilePhotoDelegate? = nil) {
        let imageVC = presentationAssembly.imageCollectionViewController()
        imageVC.changeProfilePhotoDelegate = changeProfilePhotoDelegate
        
        let navVC = UINavigationController(rootViewController: imageVC)
        navVC.modalPresentationStyle = .fullScreen
        
        emblemEmitter = EmblemEmitter(view: navVC.view)
        
        controller.present(navVC, animated: true, completion: nil)
    }
}

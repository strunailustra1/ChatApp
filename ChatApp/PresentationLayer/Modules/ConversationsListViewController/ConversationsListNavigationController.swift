//
//  RootNavigationController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 08.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class ConversationsListNavigationController: UINavigationController {
    var themesManager: ThemesManagerProtocol?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return themesManager?.getTheme().statusBarStyle ?? .default
    }
}

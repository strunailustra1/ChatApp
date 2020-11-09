//
//  RootNavigationController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 08.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class RootNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemesManager.shared.getTheme().statusBarStyle
    }
}

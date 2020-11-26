//
//  ProfileViewControllerSettings.swift
//  ChatApp
//
//  Created by Наталья Мирная on 20.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

struct ProfileViewControllerSettings {
    let themesManager: ThemesManagerProtocol
    let imageComparator: ImageComparatorProtocol
    let profileRepository: ProfileRepositoryProtocol
    let profileTextFieldDelegate: TextFieldDelegateWithCompletion
    let profileTextViewDelegate: TextViewDelegateWithCompletion
    let router: RouterProtocol
}

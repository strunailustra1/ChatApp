//
//  ThemesPickerHandler.swift
//  ChatApp
//
//  Created by Наталья Мирная on 09.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol ThemesPickerHandler {
    var themeChangeHandler: ((_ theme: Theme) -> Void) { get }
}

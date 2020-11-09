//
//  ThemesManagerProtocol.swift
//  ChatApp
//
//  Created by Наталья Мирная on 09.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol ThemesManagerProtocol {
    func getTheme() -> Theme
    func applyTheme(_ theme: Theme)
}

//
//  ThemesManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 05.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

enum Theme {
    case classic, day, night
}

class ThemesManager: ThemesPickerDelegate {
    
    public static var shared = ThemesManager()
    
    private var currentTheme: Theme = .night
    
    lazy var themeChangeHandler: ((_ theme: Theme) -> ()) = {[weak self] theme in
        print(#function, theme)
        self?.currentTheme = theme
    }
    
    init() {
        //TODO:- fill currentTheme from UserDefaults
    }
    
    func setTheme(_ theme: Theme) {
//        print(#function, theme)
//        currentTheme = theme
        //TODO:- store currentTheme from UserDefaults
    }
    
    func getTheme() -> Theme {
        currentTheme
    }
    
    func getThemesVCBackgroundColor() -> UIColor {
        switch currentTheme {
        case .classic:
            return UIColor(red: 135/256, green: 182/256, blue: 151/256, alpha: 1)
        case .day:
            return UIColor(red: 96/256, green: 153/256, blue: 237/256, alpha: 1)
        case .night:
            return UIColor(red: 25/256, green: 26/256, blue: 51/256, alpha: 1)
        }
    }
}

//
//  ThemesManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 05.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

enum Theme: Int {
    case classic, day, night
    
    var navigationBackgroundColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
        case .night:
            return  UIColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1)
        }
    }
    
    var navigationTitleColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        case .night:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var navigationBarButtonColor: UIColor {
        switch self {
        case .classic, .day, .night:
            return UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        }
    }
    
    var themesVCBackgroundColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 135 / 256, green: 182 / 256, blue: 151 / 256, alpha: 1)
        case .day:
            return UIColor(red: 96 / 256, green: 153 / 256, blue: 237 / 256, alpha: 1)
        case .night:
            return UIColor(red: 25 / 256, green: 26 / 256, blue: 51 / 256, alpha: 1)
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .classic, .day:
            return .default
        case .night:
            return .black
        }
    }
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .classic, .day:
            return .default
        case .night:
            return .lightContent
        }
    }
    
    var profileVCBackgroundColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .night:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }

    var profileVCButtonBackgroundColor: CGColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1).cgColor
        case .night:
            return UIColor(red: 0.106, green: 0.106, blue: 0.106, alpha: 1).cgColor
        }
    }
    
    var labelTextColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        case .night:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var labelBorderColor: CGColor {
        switch self {
        case .classic, .day:
            return UIColor.lightGray.cgColor
        case .night:
            return UIColor.darkGray.cgColor
        }
    }
    
    var tableViewCellBackgroundColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 173 / 256, green: 207 / 256, blue: 182 / 256, alpha: 1)
        case .day:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .night:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var tableViewSeparatorColor: UIColor {
        switch self {
        case .classic, .day:
            return  UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6)
        case .night:
            return UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
        }
    }
    
    var conversationCellOnlineBackgroundColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 1, green: 0.988, blue: 0.474, alpha: 0.3)
        case .night:
            return UIColor(red: 0, green: 21 / 255, blue: 33 / 255, alpha: 1)
        }
    }
    
    var conversationCellHistoryBackgroundColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .night:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var conversationCellMessageTextColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6)
        case .night:
            return UIColor(red: 0.553, green: 0.553, blue: 0.576, alpha: 1)
        }
    }
    
    var settingImageColor: UIImageView {
        switch self {
        case .classic, .day:
            return UIImageView(image: UIImage(named: "Icon Canvas.png"))
        case .night:
            return UIImageView(image: UIImage(named: "Icon.png"))
        }
    }
    
    var messageUpcomingBubbleViewColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
        case . day:
            return UIColor(red: 0.263, green: 0.537, blue: 0.976, alpha: 1)
        case . night:
            return UIColor(red: 0.361, green: 0.361, blue: 0.361, alpha: 1)
        }
    }
    
    var messageIncomingBubbleViewColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
        case . day:
            return UIColor(red: 0.918, green: 0.922, blue: 0.929, alpha: 1)
        case . night:
            return UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        }
    }
    
    var messageIncomingTextColor: UIColor {
        switch self {
        case .night:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .classic, .day:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var messageUpcomingTextColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        case .day, .night:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var messageHeaderBackgroundColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 0.867, green: 0.867, blue: 0.914, alpha: 0.7)
        case . night:
            return UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 0.7)
        }
    }
    
    var messageHeaderLabelColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 1)
        case .day:
            return UIColor(red: 0.024, green: 0.024, blue: 0.024, alpha: 1)
        case . night:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var messageSenderNameLabelColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 43 / 256, green: 144 / 256, blue: 126 / 256, alpha: 1)
        case . day:
            return UIColor(red: 0.263, green: 0.537, blue: 0.976, alpha: 1)
        case . night:
            return UIColor(red: 64 / 255, green: 190 / 255, blue: 178 / 255, alpha: 1)
        }
    }
    
    var messageInputBackgroundColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1)
        case .night:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var messageTextInputBorderColor: CGColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1).cgColor
        case .night:
            return UIColor(red: 0.231, green: 0.231, blue: 0.231, alpha: 1).cgColor
        }
    }
    
    var messageTextInputBackgroundColor: UIColor {
        switch self {
        case .classic, .day:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .night:
            return UIColor(red: 0.231, green: 0.231, blue: 0.231, alpha: 1)
        }
    }
    
    var messageDateLabelIncomingColor: UIColor {
        switch self {
        case .night:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .classic:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        case .day:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var messageDateLabelUpcomingColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        case .day, .night:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

class ThemesManager: ThemesPickerDelegate, ThemesPickerHandler, ThemesManagerProtocol {
    
    private var currentTheme: Theme = .night
    
    private let selectedThemeKey = "SelectedTheme"
    
    lazy var themeChangeHandler: ((_ theme: Theme) -> Void) = { [weak self] theme in
        self?.updateTheme(theme)
    }
    
    init() {
        let rawValue = UserDefaults.standard.integer(forKey: selectedThemeKey)
        currentTheme = Theme(rawValue: rawValue) ?? .classic
    }
    
    func setTheme(_ theme: Theme) {
        // updateTheme(theme)
    }
    
    func getTheme() -> Theme {
        currentTheme
    }
    
    func applyTheme(_ theme: Theme) {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: theme.navigationTitleColor]
            navBarAppearance.titleTextAttributes = [.foregroundColor: theme.navigationTitleColor]
            navBarAppearance.backgroundColor = theme.navigationBackgroundColor

            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        } else {
            // Fallback on earlier versions
            let appearance = UINavigationBar.appearance()
            appearance.barStyle = theme.barStyle
            appearance.barTintColor = theme.navigationBackgroundColor
            appearance.backgroundColor = theme.navigationBackgroundColor
            appearance.isTranslucent = false
            appearance.titleTextAttributes = [.foregroundColor: theme.navigationTitleColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: theme.navigationTitleColor]
        }
        
        let labelAppearance = UILabel.appearance()
        labelAppearance.textColor = theme.labelTextColor
        
        let secondaryLabelAppearance = ConversationSecondaryLabel.appearance()
        secondaryLabelAppearance.textColor = theme.conversationCellMessageTextColor
        
        let tableViewAppearance = UITableView.appearance()
        tableViewAppearance.backgroundColor = theme.tableViewCellBackgroundColor
        
        let tableViewCellAppearance = UITableViewCell.appearance()
        tableViewCellAppearance.backgroundColor = theme.tableViewCellBackgroundColor
        tableViewCellAppearance.tintColor = theme.labelTextColor
        tableViewCellAppearance.selectionStyle = .none
        
        UIApplication.shared.delegate?.window??.subviews.forEach({ (view: UIView) in
            view.removeFromSuperview()
            UIApplication.shared.delegate?.window??.addSubview(view)
        })
        UIApplication.shared.delegate?.window??.rootViewController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func updateTheme(_ theme: Theme) {
        currentTheme = theme
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let selectedThemeKey = self?.selectedThemeKey else { return }
            UserDefaults.standard.set(theme.rawValue, forKey: selectedThemeKey)
            UserDefaults.standard.synchronize()
        }
        
        applyTheme(theme)
    }
}

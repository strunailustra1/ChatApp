//
//  ThemesViewController.swift
//  ChatApp
//
//  Created by Наталья Мирная on 02.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    
    @IBOutlet var themesButtons: [UIButton]!
    @IBOutlet var colorLabels: [UILabel]!
    @IBOutlet var themesNamesButtons: [UIButton]!
    
    @IBOutlet weak var classicThemeButton: UIButton!
    @IBOutlet weak var dayThemeButton: UIButton!
    @IBOutlet weak var nightThemeButton: UIButton!
    
    @IBOutlet weak var classicIncomingLabel: UILabel!
    @IBOutlet weak var classicOutcomingLabel: UILabel!
    @IBOutlet weak var dayIncomingLabel: UILabel!
    @IBOutlet weak var dayOutcomingLabel: UILabel!
    @IBOutlet weak var nightIncomingLabel: UILabel!
    @IBOutlet weak var nightOutcomingLabel: UILabel!
    
    @IBOutlet weak var classicThemeName: UIButton!
    @IBOutlet weak var dayThemeName: UIButton!
    @IBOutlet weak var nightThemeName: UIButton!
    
    /*
     С делегатом не происходит retain cycle, т.к. объект ThemesManager(ThemesPickerDelegate)
     не ссылается на ThemesViewController.
     */
    weak var delegate: ThemesPickerDelegate?
    
    /*
     Между объектом ThemesManager и замыканием (объектом) ThemesManager.themeChangeHandler
     возникнет retain cycle, т.к. themeChangeHandler ссылается на self (ThemesManager),
     если в замыкании в списке захвата не указать weak self.
     */
    var themeChangeHandler: ((_ theme: Theme) -> Void)?
    
    var themesManager: ThemesManagerProtocol?
    
    static func storyboardInstance(
        themesManager: ThemesManagerProtocol,
        delegate: ThemesPickerDelegate,
        themeChangeHandler: @escaping ((_ theme: Theme) -> Void)
    ) -> ThemesViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        let themeVC = storyboard.instantiateInitialViewController() as? ThemesViewController
        
        themeVC?.themesManager = themesManager
        themeVC?.delegate = delegate
        themeVC?.themeChangeHandler = themeChangeHandler
        
        return themeVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        customizeButtons()
        customizeColorLabels()
        customizeThemesNames()
        setupCurrentTheme()
    }
    
    @IBAction func chooseClassicTheme(_ sender: UIButton) {
        chooseTheme(classicThemeButton, theme: .classic)
    }
    
    @IBAction func chooseDayTheme(_ sender: UIButton) {
        chooseTheme(dayThemeButton, theme: .day)
    }
    
    @IBAction func chooseNightTheme(_ sender: UIButton) {
        chooseTheme(nightThemeButton, theme: .night)
    }
    
    private func chooseTheme(_ sender: UIButton, theme: Theme) {
        delegate?.setTheme(theme)
        if let handler = themeChangeHandler {
            handler(theme)
        }
        
        setupCurrentTheme()
    }
    
    private func setupCurrentTheme() {
        themesButtons.forEach { (button) in
            button.isSelected = false
        }
        
        let theme = themesManager?.getTheme()
        
        switch theme {
        case .classic:
            classicThemeButton.isSelected = true
        case .day:
            dayThemeButton.isSelected = true
        case .night:
            nightThemeButton.isSelected = true
        case .none:
            break
        }
        
        view.backgroundColor = theme?.themesVCBackgroundColor
    }
    
    private func customizeButtons() {
        classicThemeButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        dayThemeButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        nightThemeButton.backgroundColor = UIColor(red: 0.024, green: 0.024, blue: 0.024, alpha: 1)
        
        for button in themesButtons {
            button.clipsToBounds = true
            button.layer.cornerRadius = 14
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1).cgColor
        }
    }
    
    private func customizeColorLabels() {
        classicIncomingLabel.backgroundColor = UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
        classicOutcomingLabel.backgroundColor = UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
        dayIncomingLabel.backgroundColor = UIColor(red: 0.918, green: 0.922, blue: 0.929, alpha: 1)
        dayOutcomingLabel.backgroundColor = UIColor(red: 0.263, green: 0.537, blue: 0.976, alpha: 1)
        nightIncomingLabel.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        nightOutcomingLabel.backgroundColor = UIColor(red: 0.361, green: 0.361, blue: 0.361, alpha: 1)
        
        for label in colorLabels {
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 8
        }
    }
    
    private func customizeThemesNames() {
        for button in themesNamesButtons {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
            button.setTitleColor(.white, for: .normal)
        }
    }
}

extension ThemesViewController {
    private func setupNavigationController() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Settings"
        navigationItem.backBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:
            UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
    }
}

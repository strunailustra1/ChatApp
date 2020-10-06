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
    
    weak var delegate: ThemesPickerDelegate?
    var themeChangeHandler: ((_ theme: Theme) -> ())?
    
    static func storyboardInstance() -> ThemesViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? ThemesViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        customizeButtons()
        customizeColorLabels()
        customizeThemesNames()
        
        switch ThemesManager.shared.getTheme() {
        case .classic:
            classicThemeButton.isSelected = true
        case .day:
            dayThemeButton.isSelected = true
        case .night:
            nightThemeButton.isSelected = true
        }

        view.backgroundColor = ThemesManager.shared.getThemesVCBackgroundColor()
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
    
    @objc func closeTheme() {
        navigationController?.popViewController(animated: true)
    }
    
    private func chooseTheme(_ sender: UIButton, theme: Theme) {
        sender.isSelected = true
        for anotherButton in themesButtons {
            if sender !== anotherButton {
                anotherButton.isSelected = false
            }
        }
        delegate?.setTheme(theme)
        if let handler = themeChangeHandler {
            handler(theme)
        }
        view.backgroundColor = ThemesManager.shared.getThemesVCBackgroundColor()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeTheme))
        navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
    }
}

class SelectedButton: UIButton {
    override var isSelected: Bool {
        didSet {
            layer.borderColor = isSelected
                ? UIColor(red: 0, green: 0.478, blue: 1, alpha: 1).cgColor
                : UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1).cgColor
            layer.borderWidth = isSelected ? 3 : 1
        }
    }
}

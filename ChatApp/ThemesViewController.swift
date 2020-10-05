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
    
    @IBOutlet weak var classicTheme: UIButton!
    @IBOutlet weak var dayTheme: UIButton!
    @IBOutlet weak var nightTheme: UIButton!
    @IBOutlet weak var classicIncomingLabel: UILabel!
    @IBOutlet weak var classicOutcomingLabel: UILabel!
    @IBOutlet weak var dayIncomingLabel: UILabel!
    @IBOutlet weak var dayOutcomingLabel: UILabel!
    @IBOutlet weak var nightIncomingLabel: UILabel!
    @IBOutlet weak var nightOutcomingLabel: UILabel!
    @IBOutlet weak var classicThemeButton: UIButton!
    @IBOutlet weak var dayThemeButton: UIButton!
    @IBOutlet weak var nightThemeButton: UIButton!
    
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
        view.backgroundColor = UIColor(red: 0.098, green: 0.21, blue: 0.379, alpha: 1)
    }
    
    @IBAction func classicThemeButton(_ sender: UIButton) {
        selectedState(sender, tag: 0)
    }
    
    @IBAction func dayThemeButton(_ sender: UIButton) {
        selectedState(sender, tag: 1)
    }
    
    @IBAction func nightThemeButton(_ sender: UIButton) {
        selectedState(sender, tag: 2)
    }
    
    private func customizeButtons() {
        classicTheme.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        dayTheme.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        nightTheme.backgroundColor = UIColor(red: 0.024, green: 0.024, blue: 0.024, alpha: 1)
        classicTheme.layer.borderColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1).cgColor
        dayTheme.layer.borderColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1).cgColor
        nightTheme.layer.borderColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1).cgColor
        
        for index in 0..<themesButtons.count {
            themesButtons[index].clipsToBounds = true
            themesButtons[index].layer.cornerRadius = 14
            themesButtons[index].layer.borderWidth = 1
        }
    }
    
    private func customizeColorLabels() {
        classicIncomingLabel.backgroundColor = UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
        classicOutcomingLabel.backgroundColor = UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
        dayIncomingLabel.backgroundColor = UIColor(red: 0.918, green: 0.922, blue: 0.929, alpha: 1)
        dayOutcomingLabel.backgroundColor = UIColor(red: 0.263, green: 0.537, blue: 0.976, alpha: 1)
        nightIncomingLabel.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        nightOutcomingLabel.backgroundColor = UIColor(red: 0.361, green: 0.361, blue: 0.361, alpha: 1)
        
        for index in 0..<colorLabels.count {
            colorLabels[index].layer.masksToBounds = true
            colorLabels[index].layer.cornerRadius = 8
        }
    }
    
    private func customizeThemesNames() {
        for index in 0..<themesNamesButtons.count {
            themesNamesButtons[index].titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
            themesNamesButtons[index].setTitleColor(.white, for: .normal)
        }
    }
    
    private func selectedState(_ sender: UIButton, tag: Int) {
        if sender.isSelected {
            sender.isSelected = false
            sender.layer.borderColor = .none
            sender.layer.borderWidth = 0
            print(sender.isSelected)
        } else if sender.isSelected == false && tag == 0 {
            sender.isSelected = true
            sender.layer.borderColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1).cgColor
            sender.layer.borderWidth = 3
            print(sender.isSelected)
        }
    }
}
extension ThemesViewController {
    private func setupNavigationController() {
        
        navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.title = "Settings"
        
        navigationItem.largeTitleDisplayMode = .never
    }
}

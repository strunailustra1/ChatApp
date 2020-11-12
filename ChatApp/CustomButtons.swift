//
//  CustomButtons.swift
//  ChatApp
//
//  Created by Наталья Мирная on 12.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

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

class UIButtonDisableColored: UIButton {
    override var isEnabled: Bool {
        didSet {
            setTitleColor(isEnabled ? UIColor.systemBlue : UIColor.gray, for: .normal)
        }
    }
}

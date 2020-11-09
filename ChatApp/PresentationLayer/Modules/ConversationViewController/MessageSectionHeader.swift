//
//  MessageSectionHeader.swift
//  ChatApp
//
//  Created by Наталья Мирная on 28.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class MessageSectionHeader: UITableViewHeaderFooterView, ConfigurableView {

    @IBOutlet weak var sectionNameLabel: UILabel!
    @IBOutlet weak var sectionView: UIView!

    typealias ConfigurationModel = MessageSectionHeaderModel
    
    struct MessageSectionHeaderModel {
        let title: String
    }
    
    func configure(with model: ConfigurationModel) {
        sectionNameLabel.text = model.title
        sectionView.layer.cornerRadius = 8
        sectionView.backgroundColor = ThemesManager.shared.getTheme().messageHeaderBackgroundColor
        sectionNameLabel.textColor = ThemesManager.shared.getTheme().messageHeaderLabelColor
        sectionNameLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
    }
}

//
//  MessageSectionHeader.swift
//  ChatApp
//
//  Created by Наталья Мирная on 28.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class MessageSectionHeader: UITableViewHeaderFooterView, ConfigurableView {
    
    typealias ConfigurationModel = MessageSectionHeaderModel
    
    @IBOutlet weak var sectionNameLabel: UILabel!
    @IBOutlet weak var sectionView: UIView!
    
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter
    }()
    
    struct MessageSectionHeaderModel {
        let date: Date
    }
    
    func configure(with model: ConfigurationModel) {
        sectionNameLabel.text = MessageSectionHeader.dateFormatter.string(from: model.date)
        sectionView.layer.cornerRadius = 8
        sectionView.backgroundColor = UIColor(red: 0.867, green: 0.867, blue: 0.914, alpha: 0.7)
        sectionNameLabel.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 1)
    }
}

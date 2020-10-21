//
//  ConversationCell.swift
//  ChatApp
//
//  Created by Наталья Мирная on 25.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell, ConfigurableView {
 
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    typealias ConfigurationModel = ConversationCellModel
    
    struct ConversationCellModel {
        let name: String
        let message: String
        let date: Date?
    }

    static let startOfDay = Calendar.current.startOfDay(for: Date())
    
    static var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter
    }()
    
    static var hourDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    func configure(with model: ConfigurationModel) {
        nameLabel.text = model.name
        messageLabel.text = model.message
        
        if let date = model.date {
            dateLabel.text = date < ConversationCell.startOfDay
                ? ConversationCell.dayDateFormatter.string(from: date)
                : ConversationCell.hourDateFormatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
        
        messageLabel.text = model.message != "" ? model.message : "No messages yet"
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
}

class ConversationSecondaryLabel: UILabel {}

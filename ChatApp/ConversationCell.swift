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
        let date: Date
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
        
        if model.message != "" {
            dateLabel.text = model.date < ConversationCell.startOfDay
                ? ConversationCell.dayDateFormatter.string(from: model.date)
                : ConversationCell.hourDateFormatter.string(from: model.date)
        } else {
            // todo что делать с датой для пустого канала
            //dateLabel.text = ""
            dateLabel.text = model.date < ConversationCell.startOfDay
                ? ConversationCell.dayDateFormatter.string(from: model.date)
                : ConversationCell.hourDateFormatter.string(from: model.date)
        }
        
        messageLabel.text = model.message != "" ? model.message : "No messages yet"
        messageLabel.textColor = ThemesManager.shared.getTheme().conversationCellMessageTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dateLabel.textColor = ThemesManager.shared.getTheme().conversationCellMessageTextColor
    }
}

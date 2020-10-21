//
//  MessageCell.swift
//  ChatApp
//
//  Created by Наталья Мирная on 27.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell, ConfigurableView {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var constraintToSenderNameLabel: NSLayoutConstraint!    
    @IBOutlet weak var constraintToViewTop: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    
    typealias ConfigurationModel = MessageCellModel
    
    struct MessageCellModel {
        let text: String
        let sender: String
        let date: Date
    }
    
    static var hourDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    func configure(with model: ConfigurationModel) {
        messageLabel.text = model.text
        bubleView.layer.cornerRadius = 8
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        senderNameLabel.text = model.sender
        senderNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        dateLabel.text = MessageCell.hourDateFormatter.string(from: model.date)
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
    }
}

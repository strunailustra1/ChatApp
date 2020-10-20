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
    
    typealias ConfigurationModel = MessageCellModel
    
    struct MessageCellModel {
        let text: String
        let sender: String
    }
    
    func configure(with model: ConfigurationModel) {
        messageLabel.text = model.text
        bubleView.layer.cornerRadius = 8
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        senderNameLabel.text = model.sender
        senderNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
}

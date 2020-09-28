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
    @IBOutlet weak var upComingLabel: UILabel!
    
    typealias ConfigurationModel = MessageCellModel
    
    func configure(with model: ConfigurationModel) {
        messageLabel.text = model.text
    }
}

struct MessageCellModel {
    let text: String
}

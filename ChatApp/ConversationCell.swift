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
        let hasUnreadMessages: Bool
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
            dateLabel.text = ""
        }
        
        messageLabel.text = model.message != "" ? model.message : "No messages yet"
        messageLabel.font = UIFont.systemFont(ofSize: 13, weight: model.hasUnreadMessages == true ? .bold : .regular)
        messageLabel.textColor = ThemesManager.shared.getTheme().conversationCellMessageTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dateLabel.textColor = ThemesManager.shared.getTheme().conversationCellMessageTextColor
    }
}

class ConversationProvider {
    
    static let name = ["Ronald", "Johnny", "Martha", "Arthur", "Morris", "Irma",
                       "Colin", "Jane", "Irma", "Karen", "Morris", "William"]
    
    static let surname = ["Robertson", "Watson", "Craig", "Bell", "Warren",
                          "Henry", "Hailey", "Williams", "Flores", "Colins"]
    
    static let message = ["An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
                          "Reprehenderit mollit excepteur labore deserunt officia laboris",
                          "",
                          "Voluptate irure aliquip consectetur commodo ex ex.",
                          "",
                          "Dolore veniam Lorem occaecat veniam irure laborum est amet.",
                          "Amet enim do laborum tempor nisi aliqua ad adipisicing.",
                          "Voluptate irure aliquip consectetur commodo ex ex.",
                          "Voluptate irure aliquip consectetur commodo ex ex.",
                          "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.",
                          "Ex Lorem veniam veniam irure sunt adipisicing culpa.",
                          "",
                          ""]
    
    static let date = [Date(timeIntervalSinceNow: -86400), Date(timeIntervalSinceNow: -186400),
                       Date(timeIntervalSinceNow: -2400), Date(timeIntervalSinceNow: -196400),
                       Date(timeIntervalSinceNow: -12400), Date(timeIntervalSinceNow: -1300),
                       Date(timeIntervalSinceNow: -400),Date(timeIntervalSinceNow: -13400),
                       Date(timeIntervalSinceNow: -36400), Date(timeIntervalSinceNow: -867700),
                       Date(timeIntervalSinceNow: -16400), Date(timeIntervalSinceNow: -128400),
                       Date(timeIntervalSinceNow: -86400), Date(timeIntervalSinceNow: -86400),
                       Date(timeIntervalSinceNow: -224400),Date(timeIntervalSinceNow: -816400),
                       Date(timeIntervalSinceNow: -126400), Date(timeIntervalSinceNow: -86500),
                       Date(timeIntervalSinceNow: -87400), Date(timeIntervalSinceNow: -3386400)]
    
    static func getMessages() -> [ConversationCell.ConversationCellModel] {
        var conversations = [ConversationCell.ConversationCellModel]()
          conversations.append(contentsOf: [])
        
        for _ in 0..<30 {
            let randomMessage = message.randomElement() ?? ""
            let conversation = ConversationCell.ConversationCellModel(
                name: "\(name.randomElement() ?? "") \(surname.randomElement() ?? "")",
                message: randomMessage,
                date: date.randomElement() ?? Date.init(),
                hasUnreadMessages: randomMessage != "" ? [true, false].randomElement() ?? false : false
            )
            
              conversations.append(conversation)
        }

          conversations.sort { $0.date > $1.date }
          conversations.sort { $0.message != "" && $1.message == "" }
        return conversations
    }
}

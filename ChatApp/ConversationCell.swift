//
//  ConversationCell.swift
//  ChatApp
//
//  Created by Наталья Мирная on 25.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell, ConfigurableView {
    
    typealias ConfigurationModel = ConversationCellModel
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    //todo два dateFormatter
    static let dateFormatter = DateFormatter()
    static let startOfDay = Calendar.current.startOfDay(for: Date())
    
    func configure(with model: ConfigurationModel) {
        nameLabel.text = model.name
        messageLabel.text = model.message
        
        ConversationCell.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        ConversationCell.dateFormatter.dateFormat = model.date < ConversationCell.startOfDay ? "dd MMM" : "HH:mm"
        dateLabel.text = ConversationCell.dateFormatter.string(from: model.date)
        
        messageLabel.text = model.message != "" ? model.message : "No messages yet"
        dateLabel.text = model.message != "" ? ConversationCell.dateFormatter.string(from: model.date) : ""
        backgroundColor = model.isOnline == true ? UIColor(red: 1, green: 0.988, blue: 0.474, alpha: 0.3) : .white
        messageLabel.font = model.hasUnreadMessages == true ? .boldSystemFont(ofSize: 13) : .systemFont(ofSize: 13)
    }
}

struct ConversationCellModel {
    let name: String
    let message: String
    let date: Date
    let isOnline: Bool
    let hasUnreadMessages: Bool
}

class Conversation {
    
    static let name = ["Ronald Robertson", "Johnny Watson", "Martha Craig", "Arthur Bell", "Jane Warren",
                       "Morris Henry", "Irma Flores", "Colin Williams", "Jane Henry", "Arthur Hailey",
                       "Irma Robertson", "John Watson", "Martha Bell", "Arthur Henry", "Morris Warren",
                       "Jane Henry", "Irma Colins", "William Williams", "Jane Hailey", "Arthur Warren",]
    static let message = ["An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
                          "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis",
                          "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.",
                          "Voluptate irure aliquip consectetur commodo ex ex.",
                          "Ex Lorem veniam veniam irure sunt adipisicing culpa.",
                          "Dolore veniam Lorem occaecat veniam irure laborum est amet.",
                          "Amet enim do laborum tempor nisi aliqua ad adipisicing.",
                          "Voluptate irure aliquip consectetur commodo ex ex.",
                          "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.",
                          "Dolore veniam Lorem occaecat veniam irure laborum est amet.",
                          "Voluptate irure aliquip consectetur commodo ex ex.",
                          "Amet enim do laborum tempor nisi aliqua ad adipisicing.",
                          "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
                          "Voluptate irure aliquip consectetur commodo ex ex.",
                          "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.",
                          "Ex Lorem veniam veniam irure sunt adipisicing culpa.",
                          "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis",
                          "",
                          "Dolore veniam Lorem occaecat veniam irure laborum est amet.",
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
    static let isOnline = [true, false, true, false, false, true, false, false, true, true,
                           true, false, true, false, false, true, false, false, true, true]
    static let hasUnreadMessages = [true, false, false, false, false, false, true, false, true, true,
                                    true, false, false, false, false, true, true, false, true, false]
    
    static func getMessages() -> [[ConversationCellModel]] {
        var conversations = [[ConversationCellModel]]()

        conversations.append(contentsOf: [[], []])
        
        for index in 0..<name.count {
            let conversation = ConversationCellModel(name: name[index],
                                                     message: message[index],
                                                     date: date[index],
                                                     isOnline: isOnline[index],
                                                     hasUnreadMessages: hasUnreadMessages[index])
            if isOnline[index] == false && message[index] == "" {
                continue
            }
            conversations[isOnline[index] ? 0 : 1].append(conversation)
        }
        
        return conversations
    }
}

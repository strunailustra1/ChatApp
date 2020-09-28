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
    
    static let dateFormatter = DateFormatter()
    static let startOfDay = Calendar.current.startOfDay(for: Date())
    
    func configure(with model: ConfigurationModel) {
        nameLabel.text = model.name
        messageLabel.text = model.message
        
        ConversationCell.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        ConversationCell.dateFormatter.dateFormat = model.date < ConversationCell.startOfDay ? "dd MMM" : "HH:mm"
        dateLabel.text = ConversationCell.dateFormatter.string(from: model.date)
        
        messageLabel.text = model.message != "" ? model.message : "No messages yet"
        backgroundColor = model.isOnline == true ? UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 0.1) : .white
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

let foo = Date(timeIntervalSinceNow: -100)

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
                          "AVoluptate irure aliquip consectetur commodo ex ex.",
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
        
        conversations.append([])
        conversations.append([])
        
        for index in 0..<name.count {
            let conversation = ConversationCellModel(name: name[index],
                                                     message: message[index],
                                                     date: date[index],
                                                     isOnline: isOnline[index],
                                                     hasUnreadMessages: hasUnreadMessages[index])
            conversations[isOnline[index] ? 0 : 1].append(conversation)
        }
        
        return conversations
    }
}

//private let conversations = [ConversationModel(name: "Ronald Robertson",
//                                               message: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
//                                               date: "24-07", isOnline: false,
//                                               hasUnreadMessages: false),
//                             ConversationModel(name: "Johnny Watson",
//                                               message: "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis",
//                                               date: "24-07",
//                                               isOnline: true,
//                                               hasUnreadMessages: true),
//                             ConversationModel(name: "Martha Craig",
//                                               message: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.",
//                                               date: "24-07",
//                                               isOnline: true,
//                                               hasUnreadMessages: false),
//                             ConversationModel(name: "Arthur Bell",
//                                               message: "Voluptate irure aliquip consectetur commodo ex ex.",
//                                               date: "24-07",
//                                               isOnline: true,
//                                               hasUnreadMessages: true),
//                             ConversationModel(name: "Jane Warren",
//                                               message: "Ex Lorem veniam veniam irure sunt adipisicing culpa.",
//                                               date: "24-07",
//                                               isOnline: true,
//                                               hasUnreadMessages: false),
//                             ConversationModel(name: "Morris Henry",
//                                               message: "Dolore veniam Lorem occaecat veniam irure laborum est amet.",
//                                               date: "24-07",
//                                               isOnline: false,
//                                               hasUnreadMessages: true),
//                             ConversationModel(name: "Irma Flores",
//                                               message: "Amet enim do laborum tempor nisi aliqua ad adipisicing.",
//                                               date: "24-07",
//                                               isOnline: true,
//                                               hasUnreadMessages: false),
//                             ConversationModel(name: "Colin Williams",
//                                               message: "AVoluptate irure aliquip consectetur commodo ex ex.",
//                                               date: "24-07",
//                                               isOnline: false,
//                                               hasUnreadMessages: true),
//                             ConversationModel(name: "Jane Henry",
//                                               message: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat.",
//                                               date: "24-07",
//                                               isOnline: false,
//                                               hasUnreadMessages: false),
//                             ConversationModel(name: "Arthur Hailey",
//                                               message: "Dolore veniam Lorem occaecat veniam irure laborum est amet.",
//                                               date: "24-07",
//                                               isOnline: false,
//                                               hasUnreadMessages: true)]

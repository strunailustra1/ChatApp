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
    
    typealias ConfigurationModel = MessageCellModel
    
    struct MessageCellModel {
        let text: String
    }
    
    func configure(with model: ConfigurationModel) {
        messageLabel.text = model.text
        bubleView.layer.cornerRadius = 8
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageLabel.textColor = .black
    }
}

struct Message {
    let text: String
    let date: Date
    let isUpcomingMessage: Bool
    
    var stringDay: String  {
        Message.dayDateFormatter.string(from: date)
    }

    static var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}

class MessageProvider {
    static let messageText = [
        "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
        "Voluptate irure aliquip consectetur commodo ex ex.",
        "Ex Lorem veniam veniam irure sunt adipisicing culpa.",
        "Dolore veniam Lorem occaecat veniam irure laborum est amet.",
        "Amet enim do laborum tempor nisi aliqua ad adipisicing.",
    ]
    
    static let date = [Date(timeIntervalSinceNow: -196400), Date(timeIntervalSinceNow: -195000),
                       Date(timeIntervalSinceNow: -188400), Date(timeIntervalSinceNow: -186000),
                       Date(timeIntervalSinceNow: -86900), Date(timeIntervalSinceNow: -86700),
                       Date(timeIntervalSinceNow: -32400), Date(timeIntervalSinceNow: -18900),
                       Date(timeIntervalSinceNow: -12400), Date(timeIntervalSinceNow: -5600),
                       Date(timeIntervalSinceNow: -2400), Date(timeIntervalSinceNow: -1200)]
    
    static func getMessages() -> [[Message]] {
        var messages = [Message]()
        
        for _ in 0..<7 {
            let message = Message(text: messageText.randomElement() ?? "",
                                  date: date.randomElement() ?? Date.init(),
                                  isUpcomingMessage: [true, false].randomElement() ?? false)
            messages.append(message)
        }
        
        messages.sort { $0.date < $1.date }
        
        var dayDict = [String: Int]()
        var index = 0
        for message in messages {
            if dayDict[message.stringDay] == nil {
                dayDict[message.stringDay] = index
                index += 1
            }
        }
        
        var result = [[Message]]()
        result.append(contentsOf: [[Message]](repeatElement([], count: dayDict.count)))
        
        for message in messages {
            let index = dayDict[message.stringDay] ?? 0
            result[index].append(message)
        }
        
        return result
    }
}

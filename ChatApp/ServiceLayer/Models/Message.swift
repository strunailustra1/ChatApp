//
//  Message.swift
//  ChatApp
//
//  Created by Наталья Мирная on 21.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct Message {
    let identifier: String
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
    
    var stringDay: String {
        Message.dayDateFormatter.string(from: created)
    }
    
    var isUpcomingMessage: Bool {
        senderId == UIDevice.current.identifierForVendor?.uuidString
    }
    
    static var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    init(content: String, profile: Profile) {
        self.content = content
        created = Date()
        senderId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        senderName = profile.fullname
        identifier = UUID().uuidString
    }
    
    init(messageDB: MessageDB) {
        identifier = messageDB.identifier
        content = messageDB.content
        created = messageDB.created
        senderId = messageDB.senderId
        senderName = messageDB.senderName
    }
    
    init?(document: FirestoreChangedDocument) {
        let data = document.data
        
        guard let content = data["content"] as? String,
            let created = data["created"] as? Timestamp,
            let senderId = data["senderId"] as? String,
            let senderName = data["senderName"] as? String
            else { return nil }
        
        self.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.created = created.dateValue()
        self.senderId = senderId
        self.senderName = senderName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.identifier = document.documentID
    }
}

extension Message: DatabaseRepresentation {
    var representation: [String: Any] {
        return [
            "content": content,
            "created": Timestamp(date: created),
            "senderId": senderId,
            "senderName": senderName
        ]
    }
}

extension Message: Comparable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.created < rhs.created
    }
}

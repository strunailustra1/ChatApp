//
//  Channel.swift
//  ChatApp
//
//  Created by Наталья Мирная on 20.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import Firebase

struct Channel {
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
    
    init(name: String) {
        identifier = UUID().uuidString
        self.name = name
        lastMessage = nil
        lastActivity = Date() // хак чтобы созданный канал сразу отображался сверху
    }
    
    init(channelDB: ChannelDB) {
        identifier = channelDB.identifier
        name = channelDB.name
        lastMessage = channelDB.lastMessage
        lastActivity = channelDB.lastActivity
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }

        identifier = document.documentID
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        lastMessage = (data["lastMessage"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? nil
        lastActivity = (data["lastActivity"] as? Timestamp)?.dateValue() ?? nil
    }
}

extension Channel: Comparable {
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    static func < (lhs: Channel, rhs: Channel) -> Bool {
        let lhsDate = lhs.lastActivity ?? Date(timeIntervalSince1970: 0)
        let rhsDate = rhs.lastActivity ?? Date(timeIntervalSince1970: 0)
      return lhsDate < rhsDate
    }
}

protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}

extension Channel: DatabaseRepresentation {
    var representation: [String: Any] {
        return [
            "name": name,
            "lastActivity": Timestamp(date: lastActivity ?? Date())
        ]
    }
}

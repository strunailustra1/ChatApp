//
//  MessageDb.swift
//  ChatApp
//
//  Created by Наталья Мирная on 26.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData

@objc(MessageDB)
public class MessageDB: NSManagedObject {
    @NSManaged public var identifier: String
    @NSManaged public var content: String
    @NSManaged public var created: Date
    @NSManaged public var senderId: String
    @NSManaged public var senderName: String
    @NSManaged public var channel: ChannelDB?
    
    @objc var formattedDate: String {
        return MessageDB.dayDateFormatter.string(from: created)
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageDB> {
        NSFetchRequest<MessageDB>(entityName: "MessageDB")
    }
    
    private static var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter
    }()
}

extension MessageDB {
    convenience init(identifier: String,
                     content: String,
                     created: Date,
                     senderId: String,
                     senderName: String,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = identifier
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = senderName
    }
    
    convenience init(message: Message, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = message.identifier
        self.content = message.content
        self.created = message.created
        self.senderId = message.senderId
        self.senderName = message.senderName
    }
    
    var about: String {
        return self.content
    }
}

extension MessageDB: NSManagedObjectDescriptionProtocol {
    override public var description: String {
        "Message id: \(identifier), senderName: \(senderName), channel: \(channel?.name ?? "")\ncontent: \(content)"
    }
}

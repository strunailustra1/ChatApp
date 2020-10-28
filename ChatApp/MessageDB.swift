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
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageDB> {
        NSFetchRequest<MessageDB>(entityName: "MessageDB")
    }
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

extension MessageDB {
    static func fetchMessages(byChannelIdentifier param: String) -> [MessageDB] {
        guard let channelDB = ChannelDB.fetchChannel(byIdentifier: param) else { return [] }

        let fetchRequest: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "channel = %@", channelDB)
        
        guard let messagesDB = try? CoreDataStack.shared.mainContext.fetch(fetchRequest) else { return [] }
        
        return messagesDB
    }
}

extension MessageDB: NSManagedObjectDescriptionProtocol {
    override public var description: String {
        "Message id: \(identifier), senderName: \(senderName), channel: \(channel?.name ?? "")\ncontent: \(content)"
    }
}

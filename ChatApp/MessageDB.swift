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
    convenience init(content: String,
                     created: Date,
                     senderId: String,
                     senderName: String,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = senderName
    }
    
    var about: String {
        return self.content
    }
}

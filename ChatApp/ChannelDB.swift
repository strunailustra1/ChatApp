//
//  ChannelDb.swift
//  ChatApp
//
//  Created by Наталья Мирная on 26.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData

@objc(ChannelDB)
public class ChannelDB: NSManagedObject {
    @NSManaged public var identifier: String
    @NSManaged public var name: String
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastActivity: Date?
    @NSManaged public var messages: NSSet?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChannelDB> {
        NSFetchRequest<ChannelDB>(entityName: "ChannelDB")
    }
}

extension ChannelDB {
    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageDB)
    
    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageDB)
    
    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)
    
    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)
}

extension ChannelDB {
    convenience init(identifier: String,
                     name: String,
                     lastMessage: String?,
                     lastActivity: Date?,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = identifier
        self.name = name
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }
    
    convenience init(channel: Channel, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = channel.identifier
        self.name = channel.name
        self.lastMessage = channel.lastMessage
        self.lastActivity = channel.lastActivity
    }
}

extension ChannelDB {
    static func fetchChannel(byIdentifier param: String) -> ChannelDB? {
        let fetchChannelRequest: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        fetchChannelRequest.predicate = NSPredicate(format: "identifier = %@", param)
        
        let channelDBList = try? CoreDataStack.shared.mainContext.fetch(fetchChannelRequest)
        
        guard let channelDB = channelDBList?.first else { return nil }
        
        return channelDB
    }
    
    static func fetchChannels() -> [ChannelDB] {
        let fetchRequest: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastActivity", ascending: false)]
        
        return (try? CoreDataStack.shared.mainContext.fetch(fetchRequest)) ?? []
    }
}

extension ChannelDB: NSManagedObjectDescriptionProtocol {
    override public var description: String {
        "Channel id: \(identifier), name: \(name)"
    }
}

extension ChannelDB {
    var about: String {
        var messages = self.messages?.allObjects.compactMap { $0 as? MessageDB } ?? []
        messages.sort { (lhs: MessageDB, rhs: MessageDB) -> Bool in
            lhs.created > rhs.created
        }
        
        var about = "\(identifier)\t\(name)\t\(messages.count) messages\n"
        for message in messages[..<min(messages.count, 2)] {
            about += "\t\t\(message.created)\t\(message.senderName)\t\(message.content)\n"
        }
        
        return about
    }
}

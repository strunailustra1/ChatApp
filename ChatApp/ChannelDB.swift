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
    
    var about: String {
        return self.identifier + "\t" + self.name
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
        guard let channelsDBList = try? CoreDataStack.shared.mainContext.fetch(ChannelDB.fetchRequest())
            as? [ChannelDB] ?? [] else { return [] }
        
        return channelsDBList
    }
}

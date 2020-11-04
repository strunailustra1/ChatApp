//
//  ChannelRepository.swift
//  ChatApp
//
//  Created by Наталья Мирная on 04.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class ChannelRepository {
    static let shared = ChannelRepository()
    
    func fetchChannel(byIdentifier id: String, from context: NSManagedObjectContext? = nil) -> ChannelDB? {
        let fetchChannelRequest: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        fetchChannelRequest.predicate = NSPredicate(format: "identifier = %@", id)
        
        let fetchContext = context ?? CoreDataStack.shared.mainContext
        
        let channelDBList = try? fetchContext.fetch(fetchChannelRequest)
        
        guard let channelDB = channelDBList?.first else { return nil }
        
        return channelDB
    }
    
    func saveChannels(_ channelsWithChangeType: [(Channel, DocumentChangeType)]) {
        CoreDataStack.shared.performSave { [weak self] (context) in
            for (channel, changeType) in channelsWithChangeType {
                if let channelInDB = self?.fetchChannel(byIdentifier: channel.identifier, from: context) {
                    if changeType == .removed {
                        context.delete(channelInDB)
                        continue
                    }
                    
                    if channelInDB.name != channel.name {
                        channelInDB.name = channel.name
                    }

                    if channelInDB.lastActivity != channel.lastActivity {
                        channelInDB.lastActivity = channel.lastActivity
                    }

                    if channelInDB.lastMessage != channel.lastMessage {
                        channelInDB.lastMessage = channel.lastMessage
                    }
                } else {
                    if changeType != .removed {
                        _ = ChannelDB(channel: channel, in: context)
                    }
                }
            }
        }
    }
    
    func deleteChannel(_ channelDBFromMainContext: ChannelDB) {
        CoreDataStack.shared.performSave { (context) in
            guard let channelDBFromSaveContext = context.object(with: channelDBFromMainContext.objectID)
                as? ChannelDB else { return }
            context.delete(channelDBFromSaveContext)
        }
    }
}

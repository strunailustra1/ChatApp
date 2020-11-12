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

protocol ChannelRepositoryProtocol {
    func createFetchedResultsController() -> NSFetchedResultsController<ChannelDB>
    func fetchChannel(byIdentifier id: String, from context: NSManagedObjectContext?) -> ChannelDB?
    func saveChannels(_ channelsWithChangeType: [(Channel, DocumentChangeType)])
    func deleteChannel(_ channelDBFromMainContext: ChannelDB)
    func deleteMissingChannels(_ channelsId: [String])
}

class ChannelRepository: ChannelRepositoryProtocol {
    
    private let persistant: PersistantProtocol
    
    init(persistant: PersistantProtocol) {
        self.persistant = persistant
    }
    
    func createFetchedResultsController() -> NSFetchedResultsController<ChannelDB> {
        let fetchRequest: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastActivity", ascending: false)]
        fetchRequest.fetchBatchSize = 30
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistant.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return fetchedResultsController
    }
    
    func fetchChannel(byIdentifier id: String, from context: NSManagedObjectContext? = nil) -> ChannelDB? {
        let fetchChannelRequest: NSFetchRequest<ChannelDB> = ChannelDB.fetchRequest()
        fetchChannelRequest.predicate = NSPredicate(format: "identifier = %@", id)
        
        let fetchContext = context ?? persistant.mainContext
        
        let channelDBList = try? fetchContext.fetch(fetchChannelRequest)
        
        guard let channelDB = channelDBList?.first else { return nil }
        
        return channelDB
    }
    
    func saveChannels(_ channelsWithChangeType: [(Channel, DocumentChangeType)]) {
        persistant.performSave { [weak self] (context) in
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
        persistant.performSave { (context) in
            guard let channelDBFromSaveContext = context.object(with: channelDBFromMainContext.objectID)
                as? ChannelDB else { return }
            context.delete(channelDBFromSaveContext)
        }
    }
    
    func deleteMissingChannels(_ channelsId: [String]) {
        persistant.performSave { (context) in
            let channelDBList = try? context.fetch(ChannelDB.fetchRequest()) as? [ChannelDB]
            channelDBList?.forEach({ (channelDB) in
                if channelsId.firstIndex(of: channelDB.identifier) == nil {
                    context.delete(channelDB)
                }
            })
        }
    }
}

//
//  MessageRepository.swift
//  ChatApp
//
//  Created by Наталья Мирная on 04.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData
import Firebase 

class MessageRepository {
    
    private let coreDataStack: CoreDataStack
    private let channelRepository: ChannelRepository

    init(coreDataStack: CoreDataStack, channelRepository: ChannelRepository) {
        self.coreDataStack = coreDataStack
        self.channelRepository = channelRepository
    }
    
    func createFetchedResultsController(channel: Channel?) -> NSFetchedResultsController<MessageDB> {
        guard let channelId = channel?.identifier else { return NSFetchedResultsController<MessageDB>() }
        let fetchRequest: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "channel.identifier = %@", channelId)
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.mainContext,
            sectionNameKeyPath: "formattedDate",
            cacheName: nil
        )
 
        return fetchedResultsController
    }
    
    func fetchMessage(byIdentifier id: String, from context: NSManagedObjectContext? = nil) -> MessageDB? {
        let fetchMessageRequest: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
        fetchMessageRequest.predicate = NSPredicate(format: "identifier = %@", id)
        
        let fetchContext = context ?? coreDataStack.mainContext
        
        let messageDBList = try? fetchContext.fetch(fetchMessageRequest)
        
        guard let messageDB = messageDBList?.first else { return nil }
        
        return messageDB
    }
    
    func saveMessages(_ messagesWithChangeType: [(Message, DocumentChangeType)], channelId: String) {
        coreDataStack.performSave { [weak self] (context) in
            guard let channelDB = self?.channelRepository.fetchChannel(byIdentifier: channelId, from: context)
                else { return }

            for (message, changeType) in messagesWithChangeType {
                if let messageInDB = self?.fetchMessage(byIdentifier: message.identifier, from: context) {
                    if changeType == .removed {
                        context.delete(messageInDB)
                        continue
                    }
                    
                    // сообщения не должны изменяться, обрабатывать это мы не будем
                    continue
                } else {
                    if changeType != .removed {
                        let messageDB = MessageDB(message: message, in: context)
                        messageDB.channel = channelDB
                    }
                }
            }
        }
    }
}

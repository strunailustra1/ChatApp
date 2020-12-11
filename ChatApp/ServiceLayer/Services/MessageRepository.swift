//
//  MessageRepository.swift
//  ChatApp
//
//  Created by Наталья Мирная on 04.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData

protocol MessageRepositoryProtocol {
    func createFetchedResultsController(channel: Channel?) -> NSFetchedResultsController<MessageDB>
    func fetchMessage(byIdentifier id: String, from context: NSManagedObjectContext?) -> MessageDB?
    func saveMessages(_ messagesWithChangeType: [(Message, FirestoreChangedDocumentType)], channelId: String)
}

class MessageRepository: MessageRepositoryProtocol {
    
    private let persistant: PersistantProtocol
    private let channelRepository: ChannelRepositoryProtocol

    init(persistant: PersistantProtocol, channelRepository: ChannelRepositoryProtocol) {
        self.persistant = persistant
        self.channelRepository = channelRepository
    }
    
    func createFetchedResultsController(channel: Channel?) -> NSFetchedResultsController<MessageDB> {
        guard let channelId = channel?.identifier else { return NSFetchedResultsController<MessageDB>() }
        let fetchRequest: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "channel.identifier = %@", channelId)
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistant.mainContext,
            sectionNameKeyPath: "formattedDate",
            cacheName: nil
        )
 
        return fetchedResultsController
    }
    
    func fetchMessage(byIdentifier id: String, from context: NSManagedObjectContext? = nil) -> MessageDB? {
        let fetchMessageRequest: NSFetchRequest<MessageDB> = MessageDB.fetchRequest()
        fetchMessageRequest.predicate = NSPredicate(format: "identifier = %@", id)
        
        let fetchContext = context ?? persistant.mainContext
        
        let messageDBList = try? fetchContext.fetch(fetchMessageRequest)
        
        guard let messageDB = messageDBList?.first else { return nil }
        
        return messageDB
    }
    
    func saveMessages(_ messagesWithChangeType: [(Message, FirestoreChangedDocumentType)], channelId: String) {
        persistant.performSave { [weak self] (context) in
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

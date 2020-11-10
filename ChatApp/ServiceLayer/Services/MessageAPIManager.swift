//
//  MessageManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 10.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import Firebase

class MessageAPIManager {
    private let messageRepository: MessageRepository
    private let firestoreDataProvider: FirestoreDataProvider
    
    init(messageRepository: MessageRepository, firestoreDataProvider: FirestoreDataProvider) {
        self.messageRepository = messageRepository
        self.firestoreDataProvider = firestoreDataProvider
    }
    
    func createMessage(channel: Channel, messageText: String) {
        let message = Message(content: messageText)
        firestoreDataProvider.createMessage(in: channel, message: message)
    }
    
    func fetchMessages(channel: Channel, completion: (() -> Void)? = nil) {
        firestoreDataProvider.getMessages(in: channel, completion: { [weak self] changes in
            self?.handleFirestoreDocumentChanges(changes, channel: channel, completion: completion)
        })
    }
    
    func removeListener() {
        firestoreDataProvider.removeMessagesListener()
    }
    
    private func handleFirestoreDocumentChanges(
        _ changes: [DocumentChange],
        channel: Channel,
        completion: (() -> Void)? = nil
    ) {
        var messagesWithChangeType = [(Message, DocumentChangeType)]()

        for change in changes {
            guard let message = Message(document: change.document) else { continue }
            messagesWithChangeType.append((message, change.type))
        }
        
        messageRepository.saveMessages(messagesWithChangeType, channelId: channel.identifier)
        
        completion?()
    }
}

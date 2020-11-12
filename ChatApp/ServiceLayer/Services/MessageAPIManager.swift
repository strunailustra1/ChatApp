//
//  MessageManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 10.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import Firebase

protocol MessageAPIManagerProtocol {
    func createMessage(channel: Channel, profile: Profile, messageText: String)
    func fetchMessages(channel: Channel, completion: (() -> Void)?)
    func removeListener()
}

class MessageAPIManager: MessageAPIManagerProtocol {
    private let messageRepository: MessageRepositoryProtocol
    private let apiDataProvider: APIDataProviderProtocol
    
    init(messageRepository: MessageRepositoryProtocol, apiDataProvider: APIDataProviderProtocol) {
        self.messageRepository = messageRepository
        self.apiDataProvider = apiDataProvider
    }
    
    func createMessage(channel: Channel, profile: Profile, messageText: String) {
        let message = Message(content: messageText, profile: profile)
        apiDataProvider.createMessage(in: channel, message: message, errorCompletion: nil)
    }
    
    func fetchMessages(channel: Channel, completion: (() -> Void)? = nil) {
        apiDataProvider.getMessages(
            in: channel,
            completion: { [weak self] changes in
                self?.handleFirestoreDocumentChanges(changes, channel: channel, completion: completion)
            },
            errorCompletion: nil
        )
    }
    
    func removeListener() {
        apiDataProvider.removeMessagesListener()
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

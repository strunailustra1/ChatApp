//
//  ChannelManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 10.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import Firebase

class ChannelAPIManager {
    private let channelRepository: ChannelRepository
    private let firestoreDataProvider: FirestoreDataProvider
    
    init(channelRepository: ChannelRepository, firestoreDataProvider: FirestoreDataProvider) {
        self.channelRepository = channelRepository
        self.firestoreDataProvider = firestoreDataProvider
    }
    
    func createChannel(channelName: String) {
        firestoreDataProvider.createChannel(channel: Channel(name: channelName))
    }
        
    func fetchChannels() {
        firestoreDataProvider.getChannels(completion: { [weak self] changes in
            self?.handleFirestoreDocumentChanges(changes)
        })
    }
    
    func deleteChannel(_ channelDBFromMainContext: ChannelDB) {
        firestoreDataProvider.deleteChannel(channel: Channel(channelDB: channelDBFromMainContext))
        channelRepository.deleteChannel(channelDBFromMainContext)
    }
    
    func deleteMissingChannels() {
        firestoreDataProvider.getChannelsId { [weak self] (channelIdList) in
            self?.channelRepository.deleteMissingChannels(channelIdList)
        }
    }
     
    func removeListener() {
        firestoreDataProvider.removeChannelsListener()
    }
    
    private func handleFirestoreDocumentChanges(_ changes: [DocumentChange]) {
        var channelsWithChangeType = [(Channel, DocumentChangeType)]()
        
        for change in changes {
            guard let channel = Channel(document: change.document) else { continue }
            channelsWithChangeType.append((channel, change.type))
        }
        
        channelRepository.saveChannels(channelsWithChangeType)
    }
}

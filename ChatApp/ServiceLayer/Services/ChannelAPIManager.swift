//
//  ChannelManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 10.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol ChannelAPIManagerProtocol {
    func createChannel(channelName: String)
    func fetchChannels()
    func deleteChannel(_ channelDBFromMainContext: ChannelDB)
    func deleteMissingChannels()
    func removeListener()
}

class ChannelAPIManager: ChannelAPIManagerProtocol {
    private let channelRepository: ChannelRepositoryProtocol
    private let apiDataProvider: APIDataProviderProtocol
    
    init(channelRepository: ChannelRepositoryProtocol, apiDataProvider: APIDataProviderProtocol) {
        self.channelRepository = channelRepository
        self.apiDataProvider = apiDataProvider
    }
    
    func createChannel(channelName: String) {
        apiDataProvider.createChannel(channel: Channel(name: channelName), errorCompletion: nil)
    }
        
    func fetchChannels() {
        apiDataProvider.getChannels(
            completion: { [weak self] changes in
                self?.handleFirestoreDocumentChanges(changes)
            },
            errorCompletion: nil
        )
    }
    
    func deleteChannel(_ channelDBFromMainContext: ChannelDB) {
        apiDataProvider.deleteChannel(channel: Channel(channelDB: channelDBFromMainContext), errorCompletion: nil)
        channelRepository.deleteChannel(channelDBFromMainContext)
    }
    
    func deleteMissingChannels() {
        apiDataProvider.getChannelsId { [weak self] (channelIdList) in
            self?.channelRepository.deleteMissingChannels(channelIdList)
        }
    }
     
    func removeListener() {
        apiDataProvider.removeChannelsListener()
    }
    
    private func handleFirestoreDocumentChanges(_ changes: [FirestoreChangedDocument]) {
        var channelsWithChangeType = [(Channel, FirestoreChangedDocumentType)]()
        
        for change in changes {
            guard let channel = Channel(document: change) else { continue }
            channelsWithChangeType.append((channel, change.type))
        }
        
        channelRepository.saveChannels(channelsWithChangeType)
    }
}

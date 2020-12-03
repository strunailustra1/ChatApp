//
//  ChannelRepositoryMock.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 03.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import Foundation
import CoreData

class ChannelRepositoryMock: ChannelRepositoryProtocol {
    
    struct SaveChannelsParams: Equatable {
        let channelWithChangeType: [(Channel, FirestoreChangedDocumentType)]
        
        static func == (lhs: ChannelRepositoryMock.SaveChannelsParams,
                        rhs: ChannelRepositoryMock.SaveChannelsParams) -> Bool {
            
            var isEqualArrays = true
            for (index, element) in lhs.channelWithChangeType.enumerated() {
                if isEqualArrays == false {
                    break
                }
                
                if rhs.channelWithChangeType.indices.contains(index) {
                    isEqualArrays = (element.0 == rhs.channelWithChangeType[index].0)
                        && (element.1 == rhs.channelWithChangeType[index].1)
                } else {
                    isEqualArrays = false
                }
            }
            
            return isEqualArrays
        }
    }
    
    struct DeleteChannelParams: Equatable {
        let channelDB: ChannelDB
    }
    
    struct DeleteMissingChannelsParams: Equatable {
        let channelsId: [String]
    }
    
    var callsCount = 0
    
    var saveChannelsParams: SaveChannelsParams!
    var deleteChannelParams: DeleteChannelParams!
    var deleteMissingChannelsParams: DeleteMissingChannelsParams!
    
    func createFetchedResultsController() -> NSFetchedResultsController<ChannelDB> {
        NSFetchedResultsController<ChannelDB>()
    }
    
    func fetchChannel(byIdentifier id: String, from context: NSManagedObjectContext?) -> ChannelDB? {
        nil
    }
    
    func saveChannels(_ channelsWithChangeType: [(Channel, FirestoreChangedDocumentType)]) {
        callsCount += 1
        saveChannelsParams = SaveChannelsParams(channelWithChangeType: channelsWithChangeType)
    }
    
    func deleteChannel(_ channelDBFromMainContext: ChannelDB) {
        callsCount += 1
        deleteChannelParams = DeleteChannelParams(channelDB: channelDBFromMainContext)
    }
    
    func deleteMissingChannels(_ channelsId: [String]) {
        callsCount += 1
        deleteMissingChannelsParams = DeleteMissingChannelsParams(channelsId: channelsId)
    }
}

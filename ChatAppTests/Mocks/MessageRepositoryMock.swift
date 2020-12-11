//
//  MessageRepositoryMock.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 03.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import Foundation
import CoreData

class MessageRepositoryMock: MessageRepositoryProtocol {
    
    struct SaveMessagesParams: Equatable {
        let messagesWithChangeType: [(Message, FirestoreChangedDocumentType)]
        
        let channelId: String
        
        static func == (lhs: MessageRepositoryMock.SaveMessagesParams,
                        rhs: MessageRepositoryMock.SaveMessagesParams) -> Bool {
            
            var isEqualArrays = true
            for (index, element) in lhs.messagesWithChangeType.enumerated() {
                if isEqualArrays == false {
                    break
                }
                
                if rhs.messagesWithChangeType.indices.contains(index) {
                    isEqualArrays = (element.0 == rhs.messagesWithChangeType[index].0)
                        && (element.1 == rhs.messagesWithChangeType[index].1)
                } else {
                    isEqualArrays = false
                }
            }
            
            return lhs.channelId == rhs.channelId && isEqualArrays
        }
    }
    
    var callsCount = 0
    
    var saveMessagesParams: SaveMessagesParams!
    
    func createFetchedResultsController(channel: Channel?) -> NSFetchedResultsController<MessageDB> {
        NSFetchedResultsController<MessageDB>()
    }
    
    func fetchMessage(byIdentifier id: String, from context: NSManagedObjectContext?) -> MessageDB? {
        nil
    }
    
    func saveMessages(_ messagesWithChangeType: [(Message, FirestoreChangedDocumentType)], channelId: String) {
        callsCount += 1
        saveMessagesParams = SaveMessagesParams(messagesWithChangeType: messagesWithChangeType, channelId: channelId)
    }
}

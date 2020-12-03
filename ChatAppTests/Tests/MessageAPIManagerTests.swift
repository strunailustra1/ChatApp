//
//  MessageAPIManagerTests.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 01.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import XCTest
import Firebase

class MessageAPIManagerTests: XCTestCase {
    
    private var apiDataProviderMock: APIDataProviderMock!
    private var messageRepositoryMock: MessageRepositoryMock!
    private var messageAPIManager: MessageAPIManager!
    
    override func setUp() {
        super.setUp()
        
        apiDataProviderMock = APIDataProviderMock()
        messageRepositoryMock = MessageRepositoryMock()
        messageAPIManager = MessageAPIManager(messageRepository: messageRepositoryMock,
                                              apiDataProvider: apiDataProviderMock)
    }
    
    override func tearDown() {
        apiDataProviderMock = nil
        messageRepositoryMock = nil
        messageAPIManager = nil
        
        super.tearDown()
    }
    
    func testRemoveListener() {
        messageAPIManager.removeListener()
        
        XCTAssertEqual(apiDataProviderMock.callsCount, 1)
    }
    
    func testCreateMessage() {
        let channel = Channel(name: "channel")
        let profile = Profile(fullname: "testName", description: "testDescription", profileImage: nil)
        let messageText = "test"
        
        messageAPIManager.createMessage(channel: channel, profile: profile, messageText: messageText)
        
        XCTAssertEqual(apiDataProviderMock.callsCount, 1)
        XCTAssertEqual(apiDataProviderMock.createMessageParams,
                       APIDataProviderMock.CreateMessageParams(
                        channel: channel,
                        message: Message(content: messageText, profile: profile))
        )
    }
    
    func testFetchMessages() {
        let changedDocuments: [FirestoreChangedDocument] = [
            FirestoreChangedDocument(type: .added, documentID: "foo", data: [
                "content": "Hello",
                "created": Timestamp(),
                "senderId": "123",
                "senderName": "John"
            ]),
            FirestoreChangedDocument(type: .modified, documentID: "bar", data: [
                "content": "Bonjour",
                "created": Timestamp(),
                "senderId": "456",
                "senderName": "Jean"
            ]),
            FirestoreChangedDocument(type: .removed, documentID: "baz", data: [
                "content": "Privet",
                "created": Timestamp(),
                "senderId": "789",
                "senderName": "Ivan"
            ])
        ]
        
        let changedMessages: [(Message, FirestoreChangedDocumentType)] = changedDocuments.map { change in
            let message = Message(document: change) ??
                Message(content: "", profile: Profile(fullname: "", description: "", profileImage: nil))
            
            return (message, change.type)
        }
        
        apiDataProviderMock.getMessagesStub = { completion in
            completion(changedDocuments)
        }
        
        let channel = Channel(name: "channel")
        
        messageAPIManager.fetchMessages(channel: channel, completion: nil)
        
        XCTAssertEqual(apiDataProviderMock.callsCount, 1)
        XCTAssertEqual(apiDataProviderMock.getMessagesParams,
                       APIDataProviderMock.GetMessagesParams(channel: channel)
        )
        
        XCTAssertEqual(messageRepositoryMock.callsCount, 1)
        XCTAssertEqual(messageRepositoryMock.saveMessagesParams,
                       MessageRepositoryMock.SaveMessagesParams(
                        messagesWithChangeType: changedMessages,
                        channelId: channel.identifier)
        )
    }
}

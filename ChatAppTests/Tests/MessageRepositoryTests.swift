//
//  MessageRepositoryTests.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 02.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import XCTest
import CoreData

class MessageRepositoryTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var persistantMock: PersistantProtocol!
    var channelRepositoryMock: ChannelRepositoryProtocol!
    var messageRepository: MessageRepository!
    
    override func setUp() {
        super.setUp()
        
        context = setupMemoryManagedObjectContext()
        persistantMock = PersistantMock(mainContext: context)
        channelRepositoryMock = ChannelRepositoryMock()
        messageRepository = MessageRepository(persistant: persistantMock, channelRepository: channelRepositoryMock)
    }

    override func tearDown() {
        context = nil
        persistantMock = nil
        channelRepositoryMock = nil
        
        super.tearDown()
    }

    func testFetchMessage() {
        persistantMock.performSave { (context) in
            let firstMessage = MessageDB(using: context)
            firstMessage?.identifier = "123"
            firstMessage?.content = "Hello"
            firstMessage?.created = Date()
            firstMessage?.senderId = "1212"
            firstMessage?.senderName = "From Trololo"
        }
        
        let existingMessage = messageRepository.fetchMessage(byIdentifier: "123", from: context)
        XCTAssertNotNil(existingMessage)
        XCTAssertEqual(existingMessage?.identifier, "123")
        
        let notExistingMessage = messageRepository.fetchMessage(byIdentifier: "321", from: context)
        XCTAssertNil(notExistingMessage)
    }
}

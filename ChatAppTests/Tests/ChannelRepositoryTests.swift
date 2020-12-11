//
//  ChannelRepositoryTests.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 03.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import XCTest
import CoreData

class ChannelRepositoryTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var persistantMock: PersistantProtocol!
    var channelRepository: ChannelRepository!
    
    override func setUp() {
        super.setUp()
        
        context = setupMemoryManagedObjectContext()
        persistantMock = PersistantMock(mainContext: context)
        channelRepository = ChannelRepository(persistant: persistantMock)
    }
    
    override func tearDown() {
        context = nil
        persistantMock = nil
        channelRepository = nil
        
        super.tearDown()
    }
    
    func testFetchChannels() {
        persistantMock.performSave { (context) in
            let channel = ChannelDB(using: context)
            channel?.identifier = "345"
            channel?.name = "Empty Channel"
            channel?.lastMessage = nil
            channel?.lastActivity = Date()
        }
        
        let existingChannel = channelRepository.fetchChannel(byIdentifier: "345", from: context)
        
        XCTAssertNotNil(existingChannel)
        XCTAssertEqual(existingChannel?.identifier, "345")
        
        let notExistingChannel = channelRepository.fetchChannel(byIdentifier: "678", from: context)
        XCTAssertNil(notExistingChannel)
    }
    
    func testDeleteChannel() {
        persistantMock.performSave { (context) in
            let channel = ChannelDB(using: context)
            channel?.identifier = "567"
            channel?.name = "Channel for delete"
            channel?.lastMessage = nil
            channel?.lastActivity = Date()
        }
        
        guard let channelForDelete = channelRepository.fetchChannel(byIdentifier: "567", from: context) else {
            XCTFail("ChannelDB not found")
            return
        }
        
        channelRepository.deleteChannel(channelForDelete)
        
        let deletedChannel = channelRepository.fetchChannel(byIdentifier: "567", from: context)
        
        XCTAssertNil(deletedChannel)
    }
}

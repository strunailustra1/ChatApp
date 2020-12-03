//
//  ChannelAPIManagerTests.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 02.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import XCTest
import Firebase
import CoreData

class ChannelAPIManagerTests: XCTestCase {
    
    private var context: NSManagedObjectContext!
    private var apiDataProviderMock: APIDataProviderMock!
    private var channelRepositoryMock: ChannelRepositoryMock!
    private var channelAPIManager: ChannelAPIManager!
    
    override func setUp() {
        super.setUp()
        
        context = setupMemoryManagedObjectContext()
        channelRepositoryMock = ChannelRepositoryMock()
        apiDataProviderMock = APIDataProviderMock()
        channelAPIManager = ChannelAPIManager(channelRepository: channelRepositoryMock,
                                              apiDataProvider: apiDataProviderMock)
    }
    
    override func tearDown() {
        context = nil
        channelRepositoryMock = nil
        apiDataProviderMock = nil
        channelAPIManager = nil
        
        super.tearDown()
    }
    
    func testRemoveListener() {
        channelAPIManager.removeListener()
        
        XCTAssertEqual(apiDataProviderMock.callsCount, 1)
    }
    
    func testCreateChannel() {
        let channelName = "channel"
        let channel = Channel(name: channelName)
        
        channelAPIManager.createChannel(channelName: channelName)
        
        XCTAssertEqual(apiDataProviderMock.callsCount, 1)
        XCTAssertEqual(apiDataProviderMock.createChannelParams,
                       APIDataProviderMock.CreateChannelParams(channel: channel))
    }
    
    func testFetchChannels() {
        let changedDocuments: [FirestoreChangedDocument] = [
            FirestoreChangedDocument(type: .added, documentID: "foo", data: [
                "name": "Trololo",
                "lastMessage": "Hello",
                "lastActivity": Timestamp()
            ]),
            FirestoreChangedDocument(type: .added, documentID: "bar", data: [
                "name": "Tweedledum",
                "lastMessage": "Bonjour",
                "lastActivity": Timestamp()
            ]),
            FirestoreChangedDocument(type: .removed, documentID: "baz", data: [
                "name": "Tweedledee",
                "lastMessage": "Privet",
                "lastActivity": Timestamp()
            ])
        ]
        
        let changedChannels: [(Channel, FirestoreChangedDocumentType)] = changedDocuments.map { change in
            let channel = Channel(document: change) ?? Channel(name: "")
            
            return (channel, change.type)
        }
        
        apiDataProviderMock.getChannelsStub = { completion in
            completion(changedDocuments)
        }
        
        channelAPIManager.fetchChannels()
        
        XCTAssertEqual(apiDataProviderMock.callsCount, 1)
        
        XCTAssertEqual(channelRepositoryMock.callsCount, 1)
        XCTAssertEqual(channelRepositoryMock.saveChannelsParams,
                       ChannelRepositoryMock.SaveChannelsParams(channelWithChangeType: changedChannels))
    }
    
    func testDeleteChannels() {
        let channel = Channel(name: "channel")
        
        guard let channelDB = ChannelDB(using: context) else { XCTFail("ChannelDB not created"); return }
        channelDB.identifier = channel.identifier
        channelDB.name = channel.name
        channelDB.lastMessage = channel.lastMessage
        channelDB.lastActivity = channel.lastActivity
        
        channelAPIManager.deleteChannel(channelDB)
        
        XCTAssertEqual(apiDataProviderMock.callsCount, 1)
        XCTAssertEqual(apiDataProviderMock.deleteChannelsParams,
                       APIDataProviderMock.DeleteChannelParams(channel: channel))
        
        XCTAssertEqual(channelRepositoryMock.callsCount, 1)
        XCTAssertEqual(channelRepositoryMock.deleteChannelParams,
                       ChannelRepositoryMock.DeleteChannelParams(channelDB: channelDB))
    }
    
    func testDeleteMissingChannels() {
        let channelsId = ["foo", "bar", "baz"]
        
        apiDataProviderMock.getChannelsIdStub = { completion in
            completion(channelsId)
        }
        
        channelAPIManager.deleteMissingChannels()
        
        XCTAssertEqual(apiDataProviderMock.callsCount, 1)
        
        XCTAssertEqual(channelRepositoryMock.callsCount, 1)
        XCTAssertEqual(channelRepositoryMock.deleteMissingChannelsParams,
                       ChannelRepositoryMock.DeleteMissingChannelsParams(channelsId: channelsId))
    }
}

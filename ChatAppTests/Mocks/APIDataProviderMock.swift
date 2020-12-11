//
//  APIDataProviderMock.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 03.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import Foundation

class APIDataProviderMock: APIDataProviderProtocol {
    
    struct CreateMessageParams: Equatable {
        let channel: Channel
        let message: Message
        
        static func == (lhs: APIDataProviderMock.CreateMessageParams,
                        rhs: APIDataProviderMock.CreateMessageParams) -> Bool {
            return lhs.channel == rhs.channel
                && lhs.message.content == rhs.message.content
                && lhs.message.senderId == rhs.message.senderId
        }
    }
    
    struct GetMessagesParams: Equatable {
        let channel: Channel
        
        static func == (lhs: APIDataProviderMock.GetMessagesParams,
                        rhs: APIDataProviderMock.GetMessagesParams) -> Bool {
            return lhs.channel == rhs.channel
        }
    }
    
    struct CreateChannelParams: Equatable {
        let channel: Channel
        
        static func == (lhs: APIDataProviderMock.CreateChannelParams,
                        rhs: APIDataProviderMock.CreateChannelParams) -> Bool {
            return lhs.channel.name == rhs.channel.name
        }
    }
    
    struct DeleteChannelParams: Equatable {
        let channel: Channel
        
        static func == (lhs: APIDataProviderMock.DeleteChannelParams,
                        rhs: APIDataProviderMock.DeleteChannelParams) -> Bool {
            return lhs.channel == rhs.channel
        }
    }
    
    var callsCount = 0
    
    var createMessageParams: CreateMessageParams!
    
    var getMessagesParams: GetMessagesParams!
    var getMessagesStub: ((@escaping ([FirestoreChangedDocument]) -> Void) -> Void)!
    
    var createChannelParams: CreateChannelParams!
    
    var getChannelsStub: ((@escaping ([FirestoreChangedDocument]) -> Void) -> Void)!
    
    var deleteChannelsParams: DeleteChannelParams!
    
    var getChannelsIdStub: ((@escaping ([String]) -> Void) -> Void)!
    
    func getChannels(completion: @escaping ([FirestoreChangedDocument]) -> Void,
                     errorCompletion: ((Error) -> Void)?) {
        callsCount += 1
        getChannelsStub(completion)
    }
    
    func getChannelsId(completion: @escaping ([String]) -> Void) {
        callsCount += 1
        getChannelsIdStub(completion)
    }
    
    func createChannel(channel: Channel, errorCompletion: ((Error) -> Void)?) {
        callsCount += 1
        createChannelParams = CreateChannelParams(channel: channel)
    }
    
    func deleteChannel(channel: Channel, errorCompletion: ((Error) -> Void)?) {
        callsCount += 1
        deleteChannelsParams = DeleteChannelParams(channel: channel)
    }
    
    func removeChannelsListener() {
        callsCount += 1
    }
    
    func getMessages(in channel: Channel,
                     completion: @escaping ([FirestoreChangedDocument]) -> Void,
                     errorCompletion: ((Error) -> Void)?) {
        callsCount += 1
        getMessagesParams = GetMessagesParams(channel: channel)
        getMessagesStub(completion)
    }
    
    func createMessage(in channel: Channel, message: Message, errorCompletion: ((Error) -> Void)?) {
        callsCount += 1
        createMessageParams = CreateMessageParams(channel: channel, message: message)
    }
    
    func removeMessagesListener() {
        callsCount += 1
    }
}

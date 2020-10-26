//
//  FirestoreDataProvider.swift
//  ChatApp
//
//  Created by Наталья Мирная on 21.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import Firebase

class FirestoreDataProvider {
    static let shared = FirestoreDataProvider()
    
    lazy private var db = Firestore.firestore()
    
    private var channelsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    
    func getChannels(completion: @escaping ([DocumentChange]) -> Void, errorCompletion: ((Error) -> Void)? = nil) {
        channelsListener = db.collection("channels").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let e = error {
                    errorCompletion?(e)
                }
                return
            }
            
            print(snapshot.documentChanges.count)
            completion(snapshot.documentChanges)
        }
    }
    
    func createChannel(channel: Channel, errorCompletion: ((Error) -> Void)? = nil) {
        db.collection("channels")
            .document(channel.identifier)
            .setData(channel.representation, completion: { error in
                if let e = error {
                    errorCompletion?(e)
                }
            })
    }
    
    func removeChannelsListener() {
        channelsListener?.remove()
    }
    
    func getMessages(in channel: Channel,
                     completion: @escaping (DocumentChange) -> Void,
                     errorCompletion: ((Error) -> Void)? = nil) {
        messagesListener = db.collection("channels").document(channel.identifier).collection("messages")
            .order(by: "created")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    if let e = error {
                        errorCompletion?(e)
                    }
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    completion(change)
                }
        }
    }
    
    func createMessage(in channel: Channel, message: Message, errorCompletion: ((Error) -> Void)? = nil) {
        db.collection("channels").document(channel.identifier).collection("messages")
            .addDocument(data: message.representation) { error in
            if let e = error {
                errorCompletion?(e)
            }
        }
    }
    
    func removeMessagesListener() {
        messagesListener?.remove()
    }
}

//
//  FirestoreDataProvider.swift
//  ChatApp
//
//  Created by Наталья Мирная on 21.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import Firebase

protocol APIDataProviderProtocol {
    func getChannels(completion: @escaping ([FirestoreChangedDocument]) -> Void,
                     errorCompletion: ((Error) -> Void)?)
    
    func getChannelsId(completion: @escaping ([String]) -> Void)
    
    func createChannel(channel: Channel,
                       errorCompletion: ((Error) -> Void)?)
    
    func deleteChannel(channel: Channel,
                       errorCompletion: ((Error) -> Void)?)
    
    func removeChannelsListener()
    
    func getMessages(in channel: Channel,
                     completion: @escaping ([FirestoreChangedDocument]) -> Void,
                     errorCompletion: ((Error) -> Void)?)
    
    func createMessage(in channel: Channel,
                       message: Message,
                       errorCompletion: ((Error) -> Void)?)
    
    func removeMessagesListener()
}

class FirestoreDataProvider: APIDataProviderProtocol {
    lazy private var db = Firestore.firestore()
    
    private var channelsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    
    func getChannels(completion: @escaping ([FirestoreChangedDocument]) -> Void,
                     errorCompletion: ((Error) -> Void)? = nil) {
        channelsListener = db.collection("channels").addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let e = error {
                    errorCompletion?(e)
                }
                return
            }
            
            guard let changes = self?.parseSnapshot(snapshot) else { return }
            
            completion(changes)
        }
    }
    
    func getChannelsId(completion: @escaping ([String]) -> Void) {
        db.collection("channels").getDocuments { (querySnaphot, _) in
            guard let snapshot = querySnaphot else { return }
            var channelsId = [String]()
            for document in snapshot.documents {
                channelsId.append(document.documentID)
            }
            completion(channelsId)
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
    
    func deleteChannel(channel: Channel, errorCompletion: ((Error) -> Void)? = nil) {
        db.collection("channels").document(channel.identifier).delete { error in
            if let e = error {
                errorCompletion?(e)
            }
        }
    }
    
    func removeChannelsListener() {
        channelsListener?.remove()
    }
    
    func getMessages(in channel: Channel,
                     completion: @escaping ([FirestoreChangedDocument]) -> Void,
                     errorCompletion: ((Error) -> Void)? = nil) {
        messagesListener = db.collection("channels").document(channel.identifier).collection("messages")
            .order(by: "created")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    if let e = error {
                        errorCompletion?(e)
                    }
                    return
                }
                
                guard let changes = self?.parseSnapshot(snapshot) else { return }
                
                completion(changes)
        }
    }
    
    func createMessage(in channel: Channel, message: Message, errorCompletion: ((Error) -> Void)? = nil) {
        db
            .collection("channels").document(channel.identifier)
            .collection("messages").document(message.identifier)
            .setData(message.representation) { error in
                if let e = error {
                    errorCompletion?(e)
                }
        }
    }
    
    func removeMessagesListener() {
        messagesListener?.remove()
    }
    
    private func parseSnapshot(_ snapshot: QuerySnapshot) -> [FirestoreChangedDocument] {
        return snapshot.documentChanges.map { change in
            return FirestoreChangedDocument(
                type: FirestoreChangedDocumentType(rawValue: change.type.rawValue) ?? .added,
                documentID: change.document.documentID,
                data: change.document.data()
            )
        }
    }
}

enum FirestoreChangedDocumentType: Int {
    case added, modified, removed
}

struct FirestoreChangedDocument {
    let type: FirestoreChangedDocumentType
    let documentID: String
    let data: [String: Any]
}

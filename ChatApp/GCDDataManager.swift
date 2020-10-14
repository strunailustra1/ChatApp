//
//  GCDDataManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 12.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class GCDDataManager: ProfileDataManagerProtocol {
    
    static var shared = GCDDataManager()
    
    private var queue: DispatchQueue
    
    init() {
        queue = DispatchQueue(label: "com.app.GCDDataManager", qos: .userInitiated, attributes: .concurrent)
    }

    func save(profile: Profile, changedFields: ProfileChangedFields, succesfullCompletion: @escaping() -> (), errorCompletion: @escaping() -> ()) {
        
        let group = DispatchGroup()
        
        var result = [Bool]()
        
        if changedFields.profileImageChanged {
            group.enter()
            queue.async {
                if let newImage = profile.profileImage, let newImageData = newImage.jpegData(compressionQuality: 1) ?? newImage.pngData() {
                    do {
                        try newImageData.write(to: ProfilePath.image.getURL())
                        result.append(true)
                    } catch {
                        result.append(false)
                    }
                }
                group.leave()
            }
        }
        
        if changedFields.fullnameChanged {
            group.enter()
            queue.async {
                do {
                    try profile.fullname.write(to: ProfilePath.fullname.getURL(), atomically: true, encoding: String.Encoding.utf8)
                    result.append(true)
                } catch {
                    result.append(false)
                }
                group.leave()
            }
        }
        
        if changedFields.descriptionChanged {
            group.enter()
            queue.async {
                do {
                    try profile.description.write(to: ProfilePath.description.getURL(), atomically: true, encoding: String.Encoding.utf8)
                    result.append(true)
                } catch {
                    result.append(false)
                }
                group.leave()
            }
        }
        
        group.notify(queue: queue) {
            if result.contains(false) {
                DispatchQueue.main.async { errorCompletion() }
            } else {
                DispatchQueue.main.async { succesfullCompletion() }
            }
        }
    }
    
    func fetch(defaultProfile: Profile, succesfullCompletion: @escaping(Profile) -> ()) {
        var image: UIImage?
        var fullname: String?
        var description: String?
        
        let group = DispatchGroup()
        
        group.enter()
        queue.async {
            image = try? UIImage(data: Data(contentsOf: ProfilePath.image.getURL()))
            group.leave()
        }
        
        group.enter()
        queue.async {
            fullname = try? String(contentsOf: ProfilePath.fullname.getURL(), encoding: .utf8)
            group.leave()
        }
        
        group.enter()
        queue.async {
            description = try? String(contentsOf: ProfilePath.description.getURL(), encoding: .utf8)
            group.leave()
        }
        
        group.notify(queue: queue) {
            let profile = Profile(fullname: fullname ?? defaultProfile.fullname,
                                  description: description ?? defaultProfile.description,
                                  profileImage: image ?? defaultProfile.profileImage)
            
            DispatchQueue.main.async { succesfullCompletion(profile) }
        }
    }
}

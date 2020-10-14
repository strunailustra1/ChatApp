//
//  GCDDataManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 12.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

//TODO:- кастомная очередь DispatchGroup
class GCDDataManager {
    
    static var shared = GCDDataManager()

    func save(profile: Profile, fullnameChanged: Bool, descriptionChanged: Bool, photoChanged: Bool, succesfullCompletion: @escaping() -> (), errorCompletion: @escaping() -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            if photoChanged, let newImage = profile.profileImage, let newImageData = newImage.jpegData(compressionQuality: 1) ?? newImage.pngData() {
                do {
                    try newImageData.write(to: ProfilePath.image.getURL())
                } catch {
                    DispatchQueue.main.async { errorCompletion() }
                    return
                }
            }
            
            if fullnameChanged {
                do {
                    try profile.fullname.write(to: ProfilePath.fullname.getURL(), atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    DispatchQueue.main.async { errorCompletion() }
                    return
                }
            }
            
            if descriptionChanged {
                do {
                    try profile.description.write(to: ProfilePath.description.getURL(), atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    DispatchQueue.main.async { errorCompletion() }
                    return
                }
            }
            
            DispatchQueue.main.async { succesfullCompletion() }
        }
    }
    
    func fetch(defaultProfile: Profile, succesfullCompletion: @escaping(Profile) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = try? UIImage(data: Data(contentsOf: ProfilePath.image.getURL()))
            let fullname = try? String(contentsOf: ProfilePath.fullname.getURL(), encoding: .utf8)
            let description = try? String(contentsOf: ProfilePath.description.getURL(), encoding: .utf8)
            
            let profile = Profile(fullname: fullname ?? defaultProfile.fullname,
                                  description: description ?? defaultProfile.description,
                                  profileImage: image ?? defaultProfile.profileImage)
            
            DispatchQueue.main.async { succesfullCompletion(profile) }
        }
    }
}

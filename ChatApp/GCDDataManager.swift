//
//  GCDDataManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 12.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

//TODO:- кастомная очередь
class GCDDataManager {
    
    static var shared = GCDDataManager()
    
    private let imageFileName = "profileImage.png"
    private let fullnameFileName = "profileFullname.txt"
    private let descriptionFileName = "profileDescription.txt"
    
    func save(profile: Profile, fullnameChanged: Bool, descriptionChanged: Bool, photoChanged: Bool, succesfullCompletion: @escaping() -> (), errorCompletion: @escaping() -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            if photoChanged, let newImage = profile.profileImage, let newImageData = newImage.jpegData(compressionQuality: 1) ?? newImage.pngData() {
                
                let imageURL = self.getDocumentsDirectory().appendingPathComponent(self.imageFileName)
                
                do {
                    try newImageData.write(to: imageURL)
                } catch {
                    DispatchQueue.main.async { errorCompletion() }
                    return
                }
            }
            
            if fullnameChanged {
                let fullnameURL = self.getDocumentsDirectory().appendingPathComponent(self.fullnameFileName)

                do {
                    try profile.fullname.write(to: fullnameURL, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    DispatchQueue.main.async { errorCompletion() }
                    return
                }
            }
            
            if descriptionChanged {
                let descriptionURL = self.getDocumentsDirectory().appendingPathComponent(self.descriptionFileName)

                do {
                    try profile.description.write(to: descriptionURL, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    DispatchQueue.main.async { errorCompletion() }
                    return
                }
            }
            
            DispatchQueue.main.async {
                succesfullCompletion()
            }
        }
    }
    
    func fetch(defaultProfile: Profile, succesfullCompletion: @escaping(Profile) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageURL = self.getDocumentsDirectory().appendingPathComponent(self.imageFileName)
            let fullnameURL = self.getDocumentsDirectory().appendingPathComponent(self.fullnameFileName)
            let descriptionURL = self.getDocumentsDirectory().appendingPathComponent(self.descriptionFileName)
            
            let image = try? UIImage(data: Data(contentsOf: imageURL))
            let fullname = try? String(contentsOf: fullnameURL, encoding: .utf8)
            let description = try? String(contentsOf: descriptionURL, encoding: .utf8)
            
            
            let profile = Profile(fullname: fullname ?? defaultProfile.fullname,
                                  description: description ?? defaultProfile.description,
                                  profileImage: image ?? defaultProfile.profileImage)
            
            succesfullCompletion(profile)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

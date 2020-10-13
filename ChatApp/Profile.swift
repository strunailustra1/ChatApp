//
//  Profile.swift
//  ChatApp
//
//  Created by Наталья Мирная on 30.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit
import Foundation

struct Profile {
    let fullname: String
    let description: String
    let profileImage: UIImage?
    
    var name: String {
        let result = fullname.split(separator: " ")
        return String(result.indices.contains(0) ? result[0] : "")
    }
    
    var surname: String {
        let result = fullname.split(separator: " ")
        return String(result.indices.contains(1) ? result[1] : "")
    }
    
    var initials: String {
        "\(name.first ?? Character(""))\(surname.first ?? Character(""))"
    }
}

class ProfileComparator {
    static func isEqualImage(oldProfile: Profile, newProfile: Profile,  completion: @escaping(_ photoHasBeenChanged: Bool) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            var isEqualImages = false
            if
                let newImage = newProfile.profileImage,
                let newImageData = newImage.jpegData(compressionQuality: 1) ?? newImage.pngData() {

                if
                    let oldImage = oldProfile.profileImage,
                    let oldImageData = oldImage.jpegData(compressionQuality: 1) ?? oldImage.pngData() {
                    isEqualImages = oldImageData == newImageData
                }
            } else {
                isEqualImages = oldProfile.profileImage == newProfile.profileImage
            }
            DispatchQueue.main.async {
                completion(!isEqualImages)
            }
        }
    }
}

class ProfileStorage {
    static var shared = Profile(fullname: "Marina Dudarenko",
                                description: "UX/UI designer, web-designer\nMoscow, Russia",
                                profileImage: nil)
}

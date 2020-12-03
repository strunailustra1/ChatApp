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
        "\(name.first ?? Character(" "))\(surname.first ?? Character(" "))"
    }
}

struct ProfileChangedFields {
    let fullnameChanged: Bool
    let descriptionChanged: Bool
    let profileImageChanged: Bool
}

extension Profile: Equatable {
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.fullname == rhs.fullname
            && lhs.description == rhs.description
            && lhs.profileImage == rhs.profileImage
    }
}

extension ProfileChangedFields: Equatable {
    static func == (lhs: ProfileChangedFields, rhs: ProfileChangedFields) -> Bool {
        return  lhs.descriptionChanged == rhs.descriptionChanged
            && lhs.fullnameChanged == rhs.fullnameChanged
            && lhs.profileImageChanged == rhs.profileImageChanged
    }
}

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
    let name: String
    let surname: String
    let profession: String
    let location: String
    var profileImage: UIImage?
    var fullname: String {
        "\(name) \(surname)"
    }
    var initials: String {
        "\(name.first ?? Character(""))\(surname.first ?? Character(""))"
    }
    var description: String {
        "\(profession)\n\(location)"
    }
}

class ProfileStorage {
    static var shared = Profile(name: "Marina",
                                surname: "Dudarenko",
                                profession: "UX/UI designer, web-designer",
                                location: "Moscow, Russia",
                                profileImage: nil)
}

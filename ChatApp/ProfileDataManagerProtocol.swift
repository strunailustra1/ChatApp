//
//  ProfileDataMangerProtocol.swift
//  ChatApp
//
//  Created by Наталья Мирная on 14.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

protocol ProfileDataManagerProtocol: class {
    func save(profile: Profile,
              changedFields: ProfileChangedFields,
              succesfullCompletion: @escaping() -> Void,
              errorCompletion: @escaping() -> Void)
    
    func fetch(defaultProfile: Profile, succesfullCompletion: @escaping(Profile) -> Void)
}

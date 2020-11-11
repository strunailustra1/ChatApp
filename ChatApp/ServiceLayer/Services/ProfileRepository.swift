//
//  ProfileRepository.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

class ProfileRepository {
    private static var shared = Profile(
        fullname: "Marina Dudarenko",
        description: "UX/UI designer, web-designer\nMoscow, Russia",
        profileImage: nil
    ) // default profile
    
    var gcdDataManager: ProfileDataManagerProtocol
    var operationDataManager: ProfileDataManagerProtocol
    
    var profile: Profile {
        get {
            return ProfileRepository.shared
        }
        set(profile) {
            ProfileRepository.shared = profile
        }
    }
    
    init(
        gcdDataManager: ProfileDataManagerProtocol,
        operationDataManager: ProfileDataManagerProtocol
    ) {
        self.gcdDataManager = gcdDataManager
        self.operationDataManager = operationDataManager
    }

    func loadFromStorage(completion: ((Profile) -> Void)? = nil) {
        let fetchDataCompletion: (Profile) -> Void = { (profile) in
            self.profile = profile
            completion?(profile)
        }
        
        let profileDataManager: ProfileDataManagerProtocol = Bool.random()
            ? gcdDataManager
            : operationDataManager
        
        profileDataManager.fetch(
            defaultProfile: self.profile,
            succesfullCompletion: fetchDataCompletion
        )
    }
}

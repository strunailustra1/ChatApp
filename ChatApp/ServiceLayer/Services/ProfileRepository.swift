//
//  ProfileRepository.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

enum ProfileSaveMethod {
    case gcd
    case operation
}

protocol ProfileRepositoryProtocol {
    var profile: Profile { get set }
    
    func loadFromStorage(completion: ((Profile) -> Void)?)
    
    func saveToStorage(
        by saveMethod: ProfileSaveMethod,
        profile: Profile,
        changedFields: ProfileChangedFields,
        succesfullCompletion: @escaping() -> Void,
        errorCompletion: @escaping() -> Void
    )
}

class ProfileRepository: ProfileRepositoryProtocol {
    private static var shared = Profile(
        fullname: "Marina Dudarenko",
        description: "UX/UI designer, web-designer\nMoscow, Russia",
        profileImage: nil
    ) // default profile
    
    private var gcdDataManager: ProfileDataManagerProtocol
    private var operationDataManager: ProfileDataManagerProtocol
    
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
    
    func saveToStorage(
        by saveMethod: ProfileSaveMethod,
        profile: Profile,
        changedFields: ProfileChangedFields,
        succesfullCompletion: @escaping() -> Void,
        errorCompletion: @escaping() -> Void
    ) {
        dataManager(by: saveMethod).save(
            profile: profile,
            changedFields: changedFields,
            succesfullCompletion: { [weak self] in
                self?.profile = profile
                succesfullCompletion()
            },
            errorCompletion: errorCompletion
        )
    }
    
    private func dataManager(by saveMethod: ProfileSaveMethod) -> ProfileDataManagerProtocol {
        switch saveMethod {
        case .gcd:
            return gcdDataManager
        case .operation:
            return operationDataManager
        }
    }
}

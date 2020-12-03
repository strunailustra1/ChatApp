//
//  GCDDataManagerMock.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 03.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import Foundation

class GCDDataManagerMock: ProfileDataManagerProtocol {
    
    struct SaveParams: Equatable {
        let profile: Profile
        let changedFields: ProfileChangedFields
        
        static func == (lhs: GCDDataManagerMock.SaveParams, rhs: GCDDataManagerMock.SaveParams) -> Bool {
            return lhs.profile == rhs.profile
                && lhs.changedFields == rhs.changedFields
        }
    }
    
    struct FetchParams: Equatable {
        let defaultProfile: Profile
    }
    
    var callsCount = 0
    
    var saveParams: SaveParams!
    
    var fetchParams: FetchParams!
    var fetchStub: ((((Profile) -> Void)?) -> Void)!
    
    func save(profile: Profile,
              changedFields: ProfileChangedFields,
              succesfullCompletion: @escaping () -> Void,
              errorCompletion: @escaping () -> Void) {
        callsCount += 1
        saveParams = SaveParams(profile: profile, changedFields: changedFields)
    }
    
    func fetch(defaultProfile: Profile, succesfullCompletion: @escaping (Profile) -> Void) {
        callsCount += 1
        fetchParams = FetchParams(defaultProfile: defaultProfile)
        fetchStub(succesfullCompletion)
    }
}

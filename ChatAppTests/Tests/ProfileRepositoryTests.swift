//
//  ProfileRepositoryTests.swift
//  ChatAppTests
//
//  Created by Наталья Мирная on 03.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

@testable import ChatApp
import XCTest

class ProfileRepositoryTests: XCTestCase {
    
    private var gcdDataManagerMock: GCDDataManagerMock!
    private var operationDataManagerMock: OperationDataManagerMock!
    private var profileRepository: ProfileRepository!
    
    override func setUp() {
        super.setUp()
        
        gcdDataManagerMock = GCDDataManagerMock()
        operationDataManagerMock = OperationDataManagerMock()
        profileRepository = ProfileRepository(gcdDataManager: gcdDataManagerMock,
                                              operationDataManager: operationDataManagerMock)
    }
    
    override func tearDown() {
        gcdDataManagerMock = nil
        operationDataManagerMock = nil
        profileRepository = nil
        
        super.tearDown()
    }
    
    func testloadFromStorage() {
        let defaultProfile = profileRepository.profile
        
        gcdDataManagerMock.fetchStub = { completion in
            completion?(defaultProfile)
        }
        
        operationDataManagerMock.fetchStub = { completion in
            completion?(defaultProfile)
        }
        
        profileRepository.loadFromStorage(by: .gcd) { (profile) in
            XCTAssertEqual(defaultProfile, profile)
        }
        
        profileRepository.loadFromStorage(by: .operation) { (profile) in
            XCTAssertEqual(defaultProfile, profile)
        }
        
        XCTAssertEqual(gcdDataManagerMock.callsCount, 1)
        XCTAssertEqual(gcdDataManagerMock.fetchParams,
                       GCDDataManagerMock.FetchParams(defaultProfile: defaultProfile))
        
        XCTAssertEqual(operationDataManagerMock.callsCount, 1)
        XCTAssertEqual(operationDataManagerMock.fetchParams,
                       OperationDataManagerMock.FetchParams(defaultProfile: defaultProfile))
    }
    
    func testSaveToStorage() {
        let profile = Profile(fullname: "Marina Dudarenko",
                              description: "UX/UI designer, web-designer\nMoscow, Russia",
                              profileImage: nil)
        
        let profileChangedFields = ProfileChangedFields(fullnameChanged: true,
                                                        descriptionChanged: true,
                                                        profileImageChanged: false)
        
        profileRepository.saveToStorage(by: ProfileStorageType.gcd,
                                        profile: profile,
                                        changedFields: profileChangedFields,
                                        succesfullCompletion: {},
                                        errorCompletion: {})
        
        profileRepository.saveToStorage(by: ProfileStorageType.operation,
                                        profile: profile,
                                        changedFields: profileChangedFields,
                                        succesfullCompletion: {},
                                        errorCompletion: {})
        
        XCTAssertEqual(gcdDataManagerMock.callsCount, 1)
        XCTAssertEqual(gcdDataManagerMock.saveParams,
                       GCDDataManagerMock.SaveParams(profile: profile, changedFields: profileChangedFields))
        
        XCTAssertEqual(operationDataManagerMock.callsCount, 1)
        XCTAssertEqual(operationDataManagerMock.saveParams,
                       OperationDataManagerMock.SaveParams(profile: profile, changedFields: profileChangedFields))
    }
}

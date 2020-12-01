//
//  ChatAppUITests.swift
//  ChatAppUITests
//
//  Created by Наталья Мирная on 30.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import XCTest
@testable import ChatApp

class ProfileViewControllerUITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        app.launch()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testTextFieldsHittable() throws {
        let goToProfileVCElement = getGoToProfileVCElement()
        XCTAssertNotNil(goToProfileVCElement)

        goToProfileVCElement?.tap()

        let editButton = app.navigationBars.buttons["Edit"].firstMatch
        _ = editButton.waitForExistence(timeout: 3)
        editButton.tap()

        let fullNameTextField = app.textFields["fullNameTextIdentifier"].firstMatch
        _ = fullNameTextField.waitForExistence(timeout: 3)
        XCTAssertTrue(fullNameTextField.isHittable)

        let descriptionNameTextView = app.textViews["descriptionTextIdentifier"].firstMatch
        _ = descriptionNameTextView.waitForExistence(timeout: 3)
        XCTAssertTrue(descriptionNameTextView.isHittable)
    }

    private func getGoToProfileVCElement() -> XCUIElement? {
        let goToProfileVCButton = app.navigationBars.buttons["goToProfileVCFromButton"].firstMatch
        _ = goToProfileVCButton.waitForExistence(timeout: 3)
        if goToProfileVCButton.exists {
            return goToProfileVCButton
        }

        let goToProfileVCImage = app.navigationBars.images["goToProfileVCFromImage"].firstMatch
        _ = goToProfileVCImage.waitForExistence(timeout: 3)
        if goToProfileVCImage.exists {
            return goToProfileVCImage
        }

        return nil
    }
}

//
//  ThemesViewControllerUITests.swift
//  ChatAppUITests
//
//  Created by Наталья Мирная on 01.12.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import XCTest
import FBSnapshotTestCase

class ThemesViewControllerUITests: FBSnapshotTestCase {
    
    private var snapshotTolerance: CGFloat = 0.0
    private var snapshotPixelTolerance: CGFloat = 0.0
    
    private var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        recordMode = false
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments += ["-SelectedTheme", "YES"]
        app.launch()
        
        let size = UIScreen.main.nativeBounds.size
        let pixelCount = size.width * size.height
        let empericalNumber: CGFloat = 7500
        snapshotTolerance = empericalNumber / pixelCount
        snapshotPixelTolerance = 0.0157
    }
    
    override func tearDown() {
        app = nil
        
        super.tearDown()
    }
    
    func testApplyTheme() {
        let goToThemesVCElement = app.navigationBars.images["goToThemesVCElement"].firstMatch
        _ = goToThemesVCElement.waitForExistence(timeout: 3)
        goToThemesVCElement.tap()
        
        let nightThemeButton = app.buttons["nightThemeApply"].firstMatch
        _ = nightThemeButton.waitForExistence(timeout: 3)
        nightThemeButton.tap()
        
        let image = app.screenshot().image
        let imageView = UIImageView(image: image)
        FBSnapshotVerifyView(
            imageView,
            identifier: "\(UIDevice.current.name)",
            perPixelTolerance: snapshotPixelTolerance,
            overallTolerance: snapshotTolerance
        )
    }
}

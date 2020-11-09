//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let rootAssembly = RootAssembly()

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Logger.shared.appDelegateLog(stateFrom: "Not Running", stateTo: "Inactive")
        return true
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.shared.appDelegateLog(stateFrom: "Inactive", stateTo: "Inactive")
        
        applyTheme()
        ProfileStorage.fetchProfileOnStartApp(window)
        FirebaseApp.configure()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootAssembly.presentationAssembly.conversationsListNavigationController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Logger.shared.appDelegateLog(stateFrom: "Active", stateTo: "Inactive")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Logger.shared.appDelegateLog(stateFrom: "Inactive", stateTo: "Active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.shared.appDelegateLog(stateFrom: "Inactive", stateTo: "Background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.shared.appDelegateLog(stateFrom: "Background", stateTo: "Inactive")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.shared.appDelegateLog(stateFrom: "Background", stateTo: "across Suspended to Not Running")
    }
    
    private func applyTheme() {
        let theme = rootAssembly.themesManager.getTheme()
        rootAssembly.themesManager.applyTheme(theme)
    }
}

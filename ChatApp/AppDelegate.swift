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
      //  Logger.shared.appDelegateLog(stateFrom: "Not Running", stateTo: "Inactive")
        rootAssembly.logger.appDelegateLog(stateFrom: "Not Running", stateTo: "Inactive", functionName: #function)
        return true
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //  Logger.shared.appDelegateLog(stateFrom: "Inactive", stateTo: "Inactive")
        rootAssembly.logger.appDelegateLog(stateFrom: "Inactive", stateTo: "Inactive", functionName: #function)
        applyTheme()
        ProfileStorage.fetchProfileOnStartApp(window)
        FirebaseApp.configure()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootAssembly.presentationAssembly.conversationsListNavigationController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
      //  Logger.shared.appDelegateLog(stateFrom: "Active", stateTo: "Inactive")
        rootAssembly.logger.appDelegateLog(stateFrom: "Active", stateTo: "Inactive", functionName: #function)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
       // Logger.shared.appDelegateLog(stateFrom: "Inactive", stateTo: "Active")
        rootAssembly.logger.appDelegateLog(stateFrom: "Inactive", stateTo: "Active", functionName: #function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
      //  Logger.shared.appDelegateLog(stateFrom: "Inactive", stateTo: "Background")
        rootAssembly.logger.appDelegateLog(stateFrom: "Inactive", stateTo: "Background", functionName: #function)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
       // Logger.shared.appDelegateLog(stateFrom: "Background", stateTo: "Inactive")
        rootAssembly.logger.appDelegateLog(stateFrom: "Background", stateTo: "Inactive", functionName: #function)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
       // Logger.shared.appDelegateLog(stateFrom: "Background", stateTo: "across Suspended to Not Running")
        rootAssembly.logger.appDelegateLog(stateFrom: "Background",
                                           stateTo: "across Suspended to Not Running",
                                           functionName: #function)
    }
    
    private func applyTheme() {
        let theme = rootAssembly.themesManager.getTheme()
        rootAssembly.themesManager.applyTheme(theme)
    }
}

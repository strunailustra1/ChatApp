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
    
    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Logger.shared.appDelegateLog(stateFrom: "Not Running", stateTo: "Inactive")
        return true
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applyTheme()
        fetchProfile()
        FirebaseApp.configure()
        Logger.shared.appDelegateLog(stateFrom: "Inactive", stateTo: "Inactive")
        
        CoreDataStack.shared.didUpdateDataBase = { stack in
            stack.printDataBaseStatistice()
        }
        CoreDataStack.shared.enableObservers()
    
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
    
    private func fetchProfile() {
        let fetchDataCompletion: (Profile) -> Void = { [weak self] (profile) in
            ProfileStorage.shared = profile
            if let navVC = self?.window?.rootViewController as? UINavigationController,
                let conversationListVC = navVC.viewControllers.first as? ConversationsListViewController {
                conversationListVC.updateNavigationRightButtonImage()
            }
        }
        
        let profileDataManager: ProfileDataManagerProtocol = Bool.random()
            ? GCDDataManager.shared
            : OperationDataManager.shared
        
        profileDataManager.fetch(defaultProfile: ProfileStorage.shared, succesfullCompletion: fetchDataCompletion)
    }
    
    private func applyTheme() {
        let theme = ThemesManager.shared.getTheme()
        ThemesManager.shared.applyTheme(theme)
    }
}

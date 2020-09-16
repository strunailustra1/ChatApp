//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Наталья Мирная on 11.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Logger.appDelegateLog(stateFrom: "Not Running", stateTo: "Inactive")
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.appDelegateLog(stateFrom: "Inactive", stateTo: "Inactive")
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "Active", stateTo: "Inactive")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "Inactive", stateTo: "Active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "Inactive", stateTo: "Background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "Background", stateTo: "Inactive")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "Background", stateTo: "across Suspended to Not Running")
    }
}

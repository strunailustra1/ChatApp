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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.appDelegateLog(stateFrom: "Not Running", stateTo: "In-Active")
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "Active", stateTo: "In-Active")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "In-Active", stateTo: "Active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "In-Active", stateTo: "Background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "Background", stateTo: "In-Active")
    }
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.appDelegateLog(stateFrom: "Background", stateTo: "Terminated")
    }
}

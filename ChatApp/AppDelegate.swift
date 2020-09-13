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
        print("Application moved from Not Running to In-Active: \(#function)")
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("Application moved from Active to In-Active: \(#function)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Application moved from In-Active to Active: \(#function)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application moved from In-Active to Background: \(#function)")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Application moved from Background to In-Active: \(#function)")
    }
    func applicationWillTerminate(_ application: UIApplication) {
        print("Application moved from Background to Terminated: \(#function)")
    }
}

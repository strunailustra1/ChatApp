//
//  Logger.swift
//  ChatApp
//
//  Created by Наталья Мирная on 13.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import os.log

class Logger {
    
    private static var subsystem = Bundle.main.bundleIdentifier
    
    private static let appCycle = OSLog(subsystem: subsystem ?? "", category: "app cycle")
    private static let viewCycle = OSLog(subsystem: subsystem ?? "", category: "view cycle")
    
    
    static func appDelegateLog(stateFrom: String, stateTo: String, functionName: String = #function) {
        #if DEBUG
        os_log("Application moved from %s to %s: %s", log: appCycle, type: .debug, stateFrom, stateTo, functionName)
        #endif
    }
    
    static func vcLog(stateFrom: String, stateTo: String, functionName: String = #function) {
        #if DEBUG
        os_log("View Controller moved from %s to %s: %s", log: viewCycle, type: .debug, stateFrom, stateTo, functionName)
        #endif
    }
    
    static func vcLog(description: String, functionName: String = #function) {
        #if DEBUG
        os_log("View Controller: %s - %s", log: viewCycle, type: .debug, description, functionName)
        #endif
    }
    
    static func vcLog(frame: String) {
        #if DEBUG
        os_log("Frame size: %s", log: viewCycle, type: .debug, frame)
        #endif
    }
}

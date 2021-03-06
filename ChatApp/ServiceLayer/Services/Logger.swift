//
//  Logger.swift
//  ChatApp
//
//  Created by Наталья Мирная on 13.09.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import os.log

enum VerboseLevel: String {
    case info
    case debug
    case none
    
    static func createFromEnvironment() -> VerboseLevel {
        let verbose = ProcessInfo.processInfo.environment["logger_verbose_level"] ?? ""
        return VerboseLevel(rawValue: verbose) ?? .info
    }
}

protocol LoggerVerboseLevel {
    var verboseLevel: VerboseLevel { get }
}

protocol LoggerAppLifeCycle {
    func appDelegateLog(stateFrom: String, stateTo: String, functionName: String)
}

protocol LoggerVCLifeCycle {
    func vcLog(stateFrom: String, stateTo: String, functionName: String)
    func vcLog(description: String, functionName: String)
    func vcLog(frame: String)
}

class Logger: LoggerVerboseLevel, LoggerAppLifeCycle, LoggerVCLifeCycle {
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? ""
    
    private let appCycle = OSLog(subsystem: subsystem, category: "app cycle")
    private let viewCycle = OSLog(subsystem: subsystem, category: "view cycle")
    
    public let verboseLevel = VerboseLevel.createFromEnvironment()
    
    func appDelegateLog(stateFrom: String, stateTo: String, functionName: String = #function) {
        os_log("Application moved from %s to %s: %s",
               log: determineLog(appCycle, type: .info),
               type: .info, stateFrom, stateTo, functionName)
    }
    
    func vcLog(stateFrom: String, stateTo: String, functionName: String = #function) {
        os_log("View Controller moved from %s to %s: %s",
               log: determineLog(viewCycle, type: .info),
               type: .info, stateFrom, stateTo, functionName)
    }
    
    func vcLog(description: String, functionName: String = #function) {
        os_log("View Controller: %s - %s",
               log: determineLog(viewCycle, type: .info),
               type: .info, description, functionName)
    }
    
    func vcLog(frame: String) {
        os_log("Frame size: %s",
               log: determineLog(viewCycle, type: .debug),
               type: .debug, frame)
    }
    
    private func determineLog(_ log: OSLog, type: OSLogType) -> OSLog {
        switch verboseLevel {
        case .none:
            return .disabled
        case .debug:
            return [OSLogType.debug, OSLogType.error, OSLogType.fault].contains(type)
                ? log
                : .disabled
        case .info:
            return log
        }
    }
}

//
//  Logger.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import OSLog

struct Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    private static let appLogger = os.Logger(subsystem: subsystem, category: "Sandbox")

    static func log(_ message: String = "", _ file: NSString = #file, _ function: String = #function, _ line: UInt = #line) {
        let baseName = file.lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        appLogger.info("\(baseName):\(function):\(line): \(message)")
    }

    static func logError(_ message: String = "", _ file: NSString = #file, _ function: String = #function, _ line: UInt = #line) {
        let baseName = file.lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        appLogger.error("\(baseName):\(function):\(line): ❌ \(message)")
    }
}

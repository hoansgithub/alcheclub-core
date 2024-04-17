//
//  ACCLogger.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
import OSLog
public class ACCLogger {
    private static let subsystem = "co.alcheclub.lib.ACCCore.ACCLogger"
    public static let defaultLogger = Logger(subsystem: subsystem, category: "VCLCoreDefaultLog")
    public static func print<T>(_ object: @autoclosure () -> T, level: OSLogType = .default, logger: Logger = defaultLogger, _ file: String = #file, _ function: String = #function, _ line: Int = #line ) {
        let value = object()
        let fileURL = (file as NSString).lastPathComponent
        let queue = Thread.isMainThread ? "UI" : "BG"
        let message = "<\(queue)> \(fileURL) \(function)[\(line)]: " + String(reflecting: value)
        switch level {
        case .debug: logger.debug("\(message)")
        case .info: logger.info("\(message)")
        case .error: logger.error("\(message)")
        case .fault: logger.fault("\(message)")
        default: logger.notice("\(message)")
        }
        
    }
}

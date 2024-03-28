//
//  Logging.swift
//  
//
//  Created by Azeem Muzammil on 2024-02-13.
//

public enum LogLevel {
    case verbose
    case info
    case warning
    case error
}

public protocol Logging {
    func log(_ str: String, logLevel: LogLevel, shouldLogContext: Bool, file: String, function: String, line: Int)
}

extension Logging {
    func log(_ str: String,
             logLevel: LogLevel,
             shouldLogContext: Bool = true,
             file: String = #file,
             function: String = #function,
             line: Int = #line) {
        log(str, logLevel: logLevel, shouldLogContext: shouldLogContext, file: file, function: function, line: line)
    }
}

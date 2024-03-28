//
//  DateUtil.swift
//
//
//  Created by Azeem Muzammil on 2024-02-06.
//

import Foundation

enum TimestampAccuracy {
    case SECOND
    case MILLISECOND
}

struct DateUtil {
    func getCurrentTimestamp(to accuracy: TimestampAccuracy) -> Double {
        let currentTimestamp = Date().timeIntervalSince1970
        switch accuracy {
        case .SECOND:
            return currentTimestamp
        case .MILLISECOND:
            return currentTimestamp * 1000
        }
    }

    func getCurrentTimeZoneMinutesFromGMT() -> Int {
        return TimeZone.current.secondsFromGMT() / 60
    }
}

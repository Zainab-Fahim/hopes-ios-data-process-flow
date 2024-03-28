//
//  Constants.swift
//
//
//  Created by Azeem Muzammil on 2024-02-06.
//

struct Constants {
    // MARK: - UserDefaultKeys
    struct UserDefaultKeys {
        static let accelerometerLastReadingEndTimeKey = "com.moht.dataProcessFlow.accelerometerLastReadingEndTimeKey"
        static let ambientLightLastReadingEndTimeKey = "com.moht.dataProcessFlow.ambientLightLastReadingEndTimeKey"
        static let deviceUsageReportLastReadingEndTimeKey =
            "com.moht.dataProcessFlow.deviceUsageReportLastReadingEndTimeKey"
        static let gpsLastReadingEndTimeKey = "com.moht.dataProcessFlow.gpsLastReadingEndTimeKey"
        static let keyboardMetricsLastReadingEndTimeKey =
            "com.moht.dataProcessFlow.keyboardMetricsLastReadingEndTimeKey"
        static let messageUsageReportLastReadingEndTimeKey =
            "com.moht.dataProcessFlow.messageUsageReportLastReadingEndTimeKey"
        static let pedometerLastReadingEndTimeKey = "com.moht.dataProcessFlow.pedometerLastReadingEndTimeKey"
        static let phoneUsageReportLastReadingEndTimeKey =
            "com.moht.dataProcessFlow.phoneUsageReportLastReadingEndTimeKey"
        static let powerStateLastReadingEndTimeKey = "com.moht.dataProcessFlow.powerStateLastReadingEndTimeKey"
        static let rotationRateLastReadingEndTimeKey = "com.moht.dataProcessFlow.rotationRateLastReadingEndTimeKey"
        static let visitsLastReadingEndTimeKey = "com.moht.dataProcessFlow.visitsLastReadingEndTimeKey"
    }

    // MARK: - Time
    struct Time {
        static let oneDay = 24 * 60 * 60
    }
}

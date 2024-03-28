//
//  DeviceUsageReportDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import Foundation

struct DeviceUsageReportData: DataStorable {
    static let source: DataSource = .deviceUsageReport
    static let headers: [String] = [
        "timestamp",
        "reportDuration",
        "totalScreenWakes",
        "totalUnlocks",
        "totalUnlockDuration",
        "appCategory",
        "appBundleId",
        "appUsageTime",
        "appTextInputSessionDuration",
        "appTextInputSessionType",
        "notificationCategory",
        "notificationBundleId",
        "notificationEvent",
        "tz"
    ]

    let timestamp: Int64
    let reportDuration: TimeInterval
    let totalScreenWakes: Int
    let totalUnlocks: Int
    let totalUnlockDuration: TimeInterval
    let appCategory: String?
    let appBundleId: String?
    let appUsageTime: TimeInterval?
    let appTextInputSessionDuration: TimeInterval?
    let appTextInputSessionType: Int?
    let notificationCategory: String?
    let notificationBundleId: String?
    let notificationEvent: Int?
    let tz: Int
}

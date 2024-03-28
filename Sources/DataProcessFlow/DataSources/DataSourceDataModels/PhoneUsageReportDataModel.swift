//
//  PhoneUsageReportDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import Foundation

struct PhoneUsageReportData: DataStorable {
    static let source: DataSource = .phoneUsageReport
    static let headers: [String] = [
        "timestamp",
        "duration",
        "noOfIncommingCalls",
        "noOfOutgoingCalls",
        "noOfUniqueContacts",
        "totalCallDuration",
        "tz"
    ]

    let timestamp: Int64
    let duration: TimeInterval
    let noOfIncommingCalls: Int
    let noOfOutgoingCalls: Int
    let noOfUniqueContacts: Int
    let totalCallDuration: TimeInterval
    let tz: Int
}

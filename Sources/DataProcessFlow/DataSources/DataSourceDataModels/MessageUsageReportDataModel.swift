//
//  MessageUsageReportDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import Foundation

struct MessageUsageReportData: DataStorable {
    static let source: DataSource = .messageUsageReport
    static let headers: [String] = [
        "timestamp",
        "duration",
        "noOfIncommingTexts",
        "noOfOutgoingTexts",
        "noOfUniqueContacts",
        "tz"
    ]

    let timestamp: Int64
    let duration: TimeInterval
    let noOfIncommingTexts: Int
    let noOfOutgoingTexts: Int
    let noOfUniqueContacts: Int
    let tz: Int
}

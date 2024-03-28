//
//  PowerStateDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

struct PowerStateData: DataStorable {
    static let source: DataSource = .powerState
    static let headers: [String] = [
        "timestamp",
        "event",
        "level",
        "tz"
    ]

    let timestamp: Int64
    let event: String
    let level: Float
    let tz: Int
}

//
//  PedometerDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import Foundation

struct PedometerData: DataStorable {
    static let source: DataSource = .pedometer
    static let headers: [String] = [
        "timestamp",
        "averageActivePace",
        "currentCadence",
        "currentPace",
        "distance",
        "startDate",
        "endDate",
        "floorsAscended",
        "floorsDescended",
        "steps",
        "tz"
    ]

    let timestamp: Int64
    let averageActivePace: NSNumber?
    let currentCadence: NSNumber?
    let currentPace: NSNumber?
    let distance: NSNumber?
    let startDate: Date
    let endDate: Date
    let floorsAscended: NSNumber?
    let floorsDescended: NSNumber?
    let steps: NSNumber
    let tz: Int
}

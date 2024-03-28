//
//  VisitsDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import SensorKit

struct VisitsData: DataStorable {
    static let source: DataSource = .visits
    static let headers: [String] = [
        "timestamp",
        "arrivalDate",
        "arrivalDuration",
        "departureDate",
        "departureDuration",
        "distanceFromHome",
        "locationCategory",
        "tz"
    ]

    let timestamp: Int64
    let arrivalDate: Date
    let arrivalDuration: TimeInterval
    let departureDate: Date
    let departureDuration: TimeInterval
    let distanceFromHome: CLLocationDistance
    let locationCategory: SRVisit.LocationCategory
    let tz: Int
}

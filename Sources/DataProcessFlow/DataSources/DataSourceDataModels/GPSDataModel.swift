//
//  GPSDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import CoreLocation

struct GPSData: DataStorable {
    static let source: DataSource = .gps
    static let headers: [String] = [
        "timestamp",
        "latitude",
        "longitude",
        "altitude",
        "accuracy",
        "locationTime",
        "provider",
        "tz"
    ]

    let timestamp: Int64
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let altitude: CLLocationDistance
    let accuracy: CLLocationAccuracy
    let locationTime: Int64
    let provider: String
    let tz: Int
}

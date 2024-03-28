//
//  AccelerometerDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-04.
//

struct AccelerometerData: DataStorable {
    static let source: DataSource = .accelerometer
    static let headers: [String] = [
        "timestamp",
        "accuracy",
        "x",
        "y",
        "z",
        "tz"
    ]

    let timestamp: Int64
    let accuracy: Double?
    let x: Double
    let y: Double
    let z: Double
    let tz: Int
}

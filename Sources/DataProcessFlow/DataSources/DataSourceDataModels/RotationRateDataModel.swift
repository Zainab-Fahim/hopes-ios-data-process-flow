//
//  RotationRateDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

struct RotationRateData: DataStorable {
    static let source: DataSource = .rotationRate
    static let headers: [String] = [
        "timestamp",
        "accuracy",
        "x",
        "y",
        "z",
        "tz"
    ]

    let timestamp: Int64
    let accuracy: Double? = nil
    let x: Double
    let y: Double
    let z: Double
    let tz: Int
}

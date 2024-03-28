//
//  AmbientLightDataModel.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

struct AmbientLightData: DataStorable {
    static let source: DataSource = .ambientLight
    static let headers: [String] = [
        "timestamp",
        "chromaticityX",
        "chromaticityY",
        "lux",
        "tz"
    ]

    let timestamp: Int64
    let chromaticityX: Float32
    let chromaticityY: Float32
    let lux: Double
    let tz: Int
}

//
//  DataSourceable.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

protocol DataSourceable {
    var lastReadingEndTime: Double { get } // This is in SRAbsoluteTime
    var timeOffset: Double { get }

    func isAvailable() -> Bool
    func startReading()
    func endReading()
}

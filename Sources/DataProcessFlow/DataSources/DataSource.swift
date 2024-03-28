//
//  File.swift
//  
//
//  Created by Azeem Muzammil on 2024-02-05.
//

enum DataSource: String {
    case accelerometer      = "accel"
    case ambientLight       = "light_ios"
    case deviceUsageReport  = "usage_ios"
    case gps                = "gps"
    case keyboardMetrics    = "keyboardMetrics_ios"
    case messageUsageReport = "textsLog_ios"
    case pedometer          = "steps_ios"
    case phoneUsageReport   = "callLog_ios"
    case powerState         = "powerState_ios"
    case rotationRate       = "gyro"
    case visits             = "visits_ios"
}

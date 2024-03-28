//
//  DataUploadError.swift
//
//
//  Created by Azeem Muzammil on 2024-02-24.
//

enum DataUploadError: ErrorRepresentable {
    case DPErrorUploadCancelled
    // Data Directory Related Errors
    case DPErrorReadingContentsOfDir
    case DPErrorMovingDataFile
    case DPErrorRemovingDataFile
}

//
//  DataProcessError.swift
//
//
//  Created by Azeem Muzammil on 2024-02-24.
//

enum DataProcessError: ErrorRepresentable {
    // Data Directory Related Errors
    case DPErrorAccessingAppSupportDir
    case DPErrorCreatingDataCollectionDir
    case DPErrorCreatingDataUploadDir
    case DPErrorCreatingTempDataUploadDir
    case DPErrorMovingDataFile
    // General Errors
    case DPErrorInitializingDataManager
}

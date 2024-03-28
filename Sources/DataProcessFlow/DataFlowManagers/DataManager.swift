//
//  DataManager.swift
//
//
//  Created by Azeem Muzammil on 2024-02-24.
//

import Foundation

class DataManager {
    static let sharedInstance = DataManager()
    
    private let collectedDataDirPath = "collectedData"
    private let uploadDataDirPath = "uploadData"
    private let uploadTempDataDirPath = "tempUploadData"
    
    private init?() {
        do {
            try createRequiredDirs()
        } catch {
            return nil
        }
    }
    
    func getCollectedDataDir() throws -> URL {
        let appSupportDir = try getAppSupportDir()
        return appSupportDir.appendingPathComponent(collectedDataDirPath)
    }

    func getUploadDataDir() throws -> URL {
        let appSupportDir = try getAppSupportDir()
        return appSupportDir.appendingPathComponent(uploadDataDirPath)
    }
    
    func getUploadTempDataDir() throws -> URL {
        let appSupportDir = try getAppSupportDir()
        return appSupportDir.appendingPathComponent(uploadTempDataDirPath)
    }
    
    private func getAppSupportDir() throws -> URL {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        if let appSupportDir {
            return appSupportDir
        }
        throw DataProcessError.DPErrorAccessingAppSupportDir
    }

    private func createRequiredDirs() throws {
        let collectedDataStoreDir = try getCollectedDataDir()
        let uploadDataStoreDir = try getUploadDataDir()
        let uploadTempDataStoreDir = try getUploadTempDataDir()

        do {
            if !FileManager.default.fileExists(atPath: collectedDataStoreDir.path) {
                try FileManager.default.createDirectory(
                    at: collectedDataStoreDir,
                    withIntermediateDirectories: true)
            }
        } catch {
            throw DataProcessError.DPErrorCreatingDataCollectionDir
        }
        
        do {
            if !FileManager.default.fileExists(atPath: uploadDataStoreDir.path) {
                try FileManager.default.createDirectory(
                    at: uploadDataStoreDir,
                    withIntermediateDirectories: true)
            }
        } catch {
            throw DataProcessError.DPErrorCreatingDataUploadDir
        }
        
        do {
            if !FileManager.default.fileExists(atPath: uploadTempDataStoreDir.path) {
                try FileManager.default.createDirectory(
                    at: uploadTempDataStoreDir,
                    withIntermediateDirectories: true)
            }
        } catch {
            throw DataProcessError.DPErrorCreatingTempDataUploadDir
        }
    }
}

//
//  DataStoreManager.swift
//
//
//  Created by Azeem Muzammil on 2024-02-06.
//

import Foundation

public class DataStoreManager {
    static let sharedInstance = DataStoreManager()

    private var logger: Logging?
    private let collectedDataDirPath = "collectedData"
    private let uploadDataDirPath = "uploadData"
    private let dataStoreQueue = DispatchQueue(label: "com.hopes.dataStoreQueue", attributes: .concurrent)
    private var dataStores: [DataSource: Any] = [:]

    private init?() {
        do {
            try createRequiredDirs()
        } catch {
            return nil
        }
    }

    func setLogger(_ logger: Logging) {
        self.logger = logger
    }

    func getDataStore<D: DataStorable>() -> DataStore<D>? {
        var dataStore: DataStore<D>?
        dataStoreQueue.sync(flags: .barrier) {
            if self.dataStores[D.source] == nil {
                let newDataStore = DataStore<D>(logger: logger, pemRSAPublicKey: "")
                self.dataStores[D.source] = newDataStore
                dataStore = newDataStore
            } else {
                dataStore = self.dataStores[D.source] as? DataStore<D>
            }
        }
        return dataStore
    }

    func getCollectedDataDir() throws -> URL {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        if let appSupportDir {
            return appSupportDir.appendingPathComponent(collectedDataDirPath)
        }
        throw DataStoreError.DPErrorAccessingFileDir
    }

    func getUploadDataDir() throws -> URL {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        if let appSupportDir {
            return appSupportDir.appendingPathComponent(uploadDataDirPath)
        }
        throw DataStoreError.DPErrorAccessingFileDir
    }

    private func createRequiredDirs() throws {
        let collectedDataStoreDir = try getCollectedDataDir()
        let uploadDataStoreDir = try getUploadDataDir()

        do {
            if !FileManager.default.fileExists(atPath: collectedDataStoreDir.path) {
                try FileManager.default.createDirectory(
                    at: collectedDataStoreDir,
                    withIntermediateDirectories: true)
            }
        } catch {
            throw DataStoreError.DPErrorCreatingDataCollectionDir
        }

        do {
            if !FileManager.default.fileExists(atPath: uploadDataStoreDir.path) {
                try FileManager.default.createDirectory(
                    at: uploadDataStoreDir,
                    withIntermediateDirectories: true)
            }
        } catch {
            throw DataStoreError.DPErrorCreatingDataUploadDir
        }
    }
}

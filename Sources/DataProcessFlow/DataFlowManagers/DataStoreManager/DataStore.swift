//
//  DataStore.swift
//  
//
//  Created by Azeem Muzammil on 2024-02-06.
//

import Foundation

class DataStore<T: DataStorable>: NSObject {
    private let logger: Logging?
    private let pemRSAPublicKey: String
    private let maxDataFileSize: Int
    private let dataStoreQueue: DispatchQueue
    private let dataWriterDelegateQueue: DispatchQueue
    private var bytesWrittenByCurrentWriter: Int
    private var currentWriter: CSVWriter<T>
    private var previourWriters: [String: CSVWriter<T>] = [:]

    init?(logger: Logging?, pemRSAPublicKey: String, maxDataFileSize: Int = 256 * 1024) {
        self.logger = logger
        self.pemRSAPublicKey = pemRSAPublicKey
        self.maxDataFileSize = maxDataFileSize
        self.dataStoreQueue = DispatchQueue(label: "com.moht.dataProcessFlow.\(T.source).dataStoreQueue")
        self.dataWriterDelegateQueue = DispatchQueue(
            label: "com.moht.dataProcessFlow.\(T.source).dataWriterDelegateQueue")

        do {
            let (dataFile, isNewFile) = try DataStore.getDataFile()
            let fileSize = try DataStore.getSize(ofFile: dataFile.path)
            let newWriter = try CSVWriter<T>(
                logger: logger,
                dataFile: dataFile,
                isNewFile: isNewFile,
                fileSize: fileSize,
                pemRSAPublicKey: pemRSAPublicKey)
            self.currentWriter = newWriter
            self.bytesWrittenByCurrentWriter = fileSize
        } catch {
            return nil
        }
    }

    // Returns (URL, Bool) => (File URL, isNewFile)
    private static func getDataFile() throws -> (URL, Bool) {
        guard let collectedDir = try DataStoreManager.sharedInstance?.getCollectedDataDir() else {
            throw DataStoreError.DPErrorInitializingDataStoreManager
        }
        guard let collectedDataFiles = try? FileManager.default.contentsOfDirectory(atPath: collectedDir.path) else {
            throw DataStoreError.DPErrorInitializingDataStoreManager
        }
        for collectedDataFile in collectedDataFiles where collectedDataFile.hasPrefix(T.source.rawValue) {
            return (collectedDir.appendingPathComponent(collectedDataFile), false)
        }
        return (try initNewDataFile(), true)
    }

    private static func initNewDataFile() throws -> URL {
        guard let collectedDir = try DataStoreManager.sharedInstance?.getCollectedDataDir() else {
            throw DataStoreError.DPErrorInitializingDataStoreManager
        }

        // Initialize DataFile URL
        let fileName = T.source.rawValue + "_" + String(Int64(DateUtil().getCurrentTimestamp(to: .MILLISECOND)))
        let dataFile = collectedDir.appendingPathComponent(fileName).appendingPathExtension("csv.raw")
        // Create the DataFile with empty data.
        do {
            try "".write(to: dataFile, atomically: true, encoding: .utf8)
        } catch {
            throw DataStoreError.DPErrorWritingDataToFile
        }
        return dataFile
    }

    private static func getSize(ofFile path: String) throws -> Int {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            return Int(attr.fileSize())
        } catch {
            throw DataStoreError.DPErrorReadingFileAttributes
        }
    }

    func store(_ data: T, completionHandler: @escaping (DataStoreError?) -> Void) {
        dataStoreQueue.async { [unowned self] in
            if bytesWrittenByCurrentWriter > maxDataFileSize {
                storeLast(data, completionHandler: completionHandler)
            } else {
                let bytesWritten = currentWriter.write(data, isLast: false, completionHandler: completionHandler)
                bytesWrittenByCurrentWriter += bytesWritten
            }
        }
    }

    func close(completionHandler: @escaping (DataStoreError?) -> Void) {
        dataStoreQueue.async { [unowned self] in
            storeLast(nil, completionHandler: completionHandler)
        }
    }

    private func storeLast(_ data: T?, completionHandler: @escaping (DataStoreError?) -> Void) {
        let bytesWritten = currentWriter.write(data, isLast: true) { error in
            completionHandler(error)
            return
        }

        bytesWrittenByCurrentWriter += bytesWritten
        // Finalize writes to the existing file and start a new writer.
        previourWriters[currentWriter.getId()] = currentWriter
        do {
            let newDataFile = try DataStore.initNewDataFile()
            let newWriter = try CSVWriter<T>(
                logger: logger,
                dataFile: newDataFile,
                isNewFile: true,
                fileSize: 0,
                pemRSAPublicKey: pemRSAPublicKey)
            currentWriter = newWriter
            bytesWrittenByCurrentWriter = 0

            currentWriter.delegate = self
        } catch {
            logger?.log("Failed to create new data file or failed to initialize CSV writer", logLevel: .error)
            completionHandler(error as? DataStoreError)
            return
        }
    }
}

// MARK: - DataWriterDelegate
extension DataStore: DataWriterDelegate {
    func dataWriter(didCloseFor writerId: String) {
        dataWriterDelegateQueue.async { [unowned self] in
            previourWriters.removeValue(forKey: writerId)
        }
    }
}

//
//  DataWriter.swift
//
//
//  Created by Azeem Muzammil on 2024-02-14.
//

import Foundation
import CryptoKit

protocol DataWriterDelegate: NSObject {
    func dataWriter(didCloseFor writerId: String)
}

class DataWriter {
    let logger: Logging?
    let dataFile: URL
    private let dataWriteChannelQueue: DispatchQueue
    private let dataWriteChannelHandlerQueue: DispatchQueue
    private var bytesQueuedToWrite: Int
    private var bytesWritten: Int
    private var pendingWrites: Int
    private var isSubmissionsPending: Bool
    
    private lazy var dataFileHandle: FileHandle? = {
        try? FileHandle(forWritingTo: dataFile)
    }()
    private lazy var dataWriteChannel: DispatchIO? = {
        if let dataFileHandle {
            guard let _ = try? dataFileHandle.seekToEnd() else {
                logger?.log(
                    "FileHandle for datasource \"\(String(describing: self))\" failed to seek to end.",
                    logLevel: .error)
                return nil
            }
            return DispatchIO(
                type: .stream,
                fileDescriptor: dataFileHandle.fileDescriptor,
                queue: dataWriteChannelQueue,
                cleanupHandler: { errorNo in
                    if errorNo == 0 {
                        self.logger?.log(
                            "Date write operation for datasource \"\(String(describing: self))\" " +
                            "is completed successfully",
                            logLevel: .info)
                    } else {
                        self.logger?.log(
                            "Date write operation for dataSource \"\(String(describing: self))\" " +
                            "is failed with error: \(errorNo)",
                            logLevel: .error)
                    }
                }
            )
        } else {
            logger?.log(
                "FileHandle for dataSource \"\(String(describing: self))\" failed to initialize",
                logLevel: .error)
            return nil
        }
    }()
    
    weak var delegate: DataWriterDelegate?
    
    init(logger: Logging?, dataFile: URL, fileSize: Int) {
        self.logger = logger
        self.dataFile = dataFile
        self.dataWriteChannelQueue = DispatchQueue(
            label: "com.moht.dataProcessFlow.\(dataFile.lastPathComponent).dataWriteChannelQueue",
            qos: .default)
        self.dataWriteChannelHandlerQueue = DispatchQueue(
            label: "com.moht.dataProcessFlow.\(dataFile.lastPathComponent).dataWriteChannelHandlerQueue",
            qos: .background)
        self.bytesQueuedToWrite = fileSize
        self.bytesWritten = fileSize
        self.pendingWrites = 0
        self.isSubmissionsPending = true
    }
    
    func getId() -> String {
        return dataFile.lastPathComponent
    }
    
    func writeData(_ data: Data, isLast: Bool, completionHandler: @escaping (DataStoreError?) -> Void) {
        write(data, isLast: isLast) { error in
            completionHandler(error)
        }
    }
    
    func endWriting() throws {
        // Implement for any cleanups on end of writing to a file.
    }

    private func write(_ data: Data, isLast: Bool, completionHandler: @escaping (DataStoreError?) -> Void) {
        guard let dataWriteChannel else {
            completionHandler(DataStoreError.DPErrorInitializingFileHandle)
            return
        }
        
        let dispatchData = data.withUnsafeBytes { unsafeRawBuffPtr in
            DispatchData(bytes: unsafeRawBuffPtr)
        }
        
        dataWriteChannelHandlerQueue.sync {
            bytesQueuedToWrite += data.count
            pendingWrites += 1
            isSubmissionsPending = !isLast
        }
        dataWriteChannel.write(
            offset: 0,
            data: dispatchData,
            queue: dataWriteChannelHandlerQueue,
            ioHandler: { [unowned self] done, remainingData, errorNo in
                bytesWritten += (data.count - (remainingData?.count).orZero)
                
                if done {
                    pendingWrites -= 1
                    if pendingWrites == 0 && bytesWritten == bytesQueuedToWrite && !isSubmissionsPending {
                        try? close()
                    }
                    if pendingWrites >= 0 {
                        if errorNo != 0 {
                            self.logger?.log(
                                "Failed to write datapoint for datasource \"\(String(describing: self))\" " +
                                "due to error: \(errorNo)",
                                logLevel: .error)
                            completionHandler(DataStoreError.DPErrorWritingDataToFile)
                            return
                        }
                        completionHandler(nil)
                    } else {
                        logger?.log(
                            "Fatal error occured for datasource \"\(String(describing: self))\"." +
                            " More data were writted than submitted, this can never happen.",
                            logLevel: .error)
                        completionHandler(DataStoreError.DPErrorFatal)
                    }
                } else {
                    logger?.log(
                        "Part of the data is written for datasource \"\(String(describing: self))\", " +
                        "\((remainingData?.count).orZero) bytes of data is remainint to write.",
                        logLevel: .warning)
                }
            }
        )
    }

    private func close() throws {
        // Close data writer objects.
        do {
            dataWriteChannel?.close()
            try dataFileHandle?.close()
        } catch {
            logger?.log(
                "Failed to close FileHandle for datasource \"\(String(describing: self))\". Due to error: \(error)",
                logLevel: .error)
            throw DataStoreError.DPErrorClosingFileHandle
        }

        try endWriting()

        delegate?.dataWriter(didCloseFor: getId())
        logger?.log("Closed the FileHandle for datasource \"\(String(describing: self))\".", logLevel: .info)
    }
}

////
////  DataUploader.swift
////
////
////  Created by Azeem Muzammil on 2024-02-24.
////
//
//import Foundation
//
//class DataUploader {
//    private let logger: Logger?
//    private let networkService: NetworkService
//    private let uploadBatchSize: Int
//    private let dataUploadGroup: DispatchGroup
//    private let dataUploadQueue: DispatchQueue
//    private let dataUploadTaskHandlerQueue: DispatchQueue
//    private let dataUploadSemaphore: DispatchSemaphore
//    private let removalFailedFilesStoreKey = "com.moht.removalFailedFilesStoreKey"
//    private var uploadTasks: [String: DataUploadTask] = [:]
//    
//    init(logger: Logger?, networkService: NetworkService, uploadBatchSize: Int, concurrentUploads: Int) {
//        self.logger = logger
//        self.networkService = networkService
//        self.uploadBatchSize = uploadBatchSize
//        self.dataUploadGroup = DispatchGroup()
//        self.dataUploadQueue = DispatchQueue(
//            label: "com.moht.dataProcessFlow.dataUploadQueue",
//            qos: .background,
//            attributes: .concurrent)
//        self.dataUploadTaskHandlerQueue = DispatchQueue(
//            label: "com.moht.dataProcessFlow.dataUploadTaskHandlerQueue",
//            qos: .background)
//        self.dataUploadSemaphore = DispatchSemaphore(value: concurrentUploads)
//    }
//
//    func upload(completionHandler: @escaping ([Error]?) -> Void) {
//        DispatchQueue.global(qos: .background).async { [unowned self] in
//            var uploadErrors: [Error] = []
//            do {
//                let uploadFiles = try prepareToUpload()
//                for uploadFile in uploadFiles {
//                    dataUploadGroup.enter()
//                    dataUploadSemaphore.wait()
//                    let uploadTask = DataUploadTask(
//                        networkService: networkService,
//                        dataFile: uploadFile,
//                        queue: dataUploadQueue
//                    ) { uploadTaskResult in
//                        self.dataUploadTaskHandlerQueue.async {
//                            switch uploadTaskResult {
//                            case .success:
//                                self.removeAfterUpload(from: uploadFile)
//                            case .failure(let error):
//                                uploadErrors.append(error)
//                            }
//                            self.dataUploadSemaphore.signal()
//                            self.dataUploadGroup.leave()
//                            self.uploadTasks.removeValue(forKey: uploadFile.lastPathComponent)
//                        }
//                    }
//                    dataUploadTaskHandlerQueue.sync {
//                        uploadTasks[uploadFile.lastPathComponent] = uploadTask
//                    }
//                    uploadTask.upload()
//                }
//                dataUploadGroup.notify(queue: .main) {
//                    completionHandler(uploadErrors.isEmpty ? nil : uploadErrors)
//                }
//            } catch {
//                completionHandler([error])
//            }
//        }
//    }
//
//    private func prepareToUpload() throws -> [URL] {
//        // Remove leftovers
//        let removalFailedFiles = (UserDefaults.standard.array(forKey: removalFailedFilesStoreKey) as? [URL]) ?? []
//        for removalFailedFile in removalFailedFiles {
//            try remove(from: removalFailedFile)
//            var tempRemovalFailedFiles = (UserDefaults.standard.array(forKey: removalFailedFilesStoreKey) as? [URL]) ??
//                []
//            let removalFailedFileIdx = tempRemovalFailedFiles.firstIndex(of: removalFailedFile)
//            if let removalFailedFileIdx {
//                tempRemovalFailedFiles.remove(at: removalFailedFileIdx)
//            }
//            UserDefaults.standard.setValue(tempRemovalFailedFiles, forKey: removalFailedFilesStoreKey)
//        }
//        
//        // Move Upload data to temp dir
//        let uploadDataDir = try DataManager.sharedInstance?.getUploadDataDir()
//        let uploadTempDataDir = try DataManager.sharedInstance?.getUploadTempDataDir()
//        
//        guard let uploadDataDir, let uploadTempDataDir else {
//            logger?.log("Failed to initialize DataManager.", logLevel: .error)
//            throw DataProcessError.DPErrorInitializingDataManager
//        }
//        
//        let uploadFiles: [String]
//        let remainingFiles: [String]
//        do {
//            uploadFiles = try FileManager.default.contentsOfDirectory(atPath: uploadDataDir.path)
//            remainingFiles = try FileManager.default.contentsOfDirectory(atPath: uploadTempDataDir.path)
//        } catch {
//            logger?.log("Failed to read contents of Upload Dir", logLevel: .error)
//            throw DataUploadError.DPErrorReadingContentsOfDir
//        }
//        
//        var movedFiles = remainingFiles.count
//        for uploadFile in uploadFiles.sorted() {
//            if movedFiles >= uploadBatchSize {
//                break
//            }
//            let uploadFileURL = uploadDataDir.appendingPathComponent(uploadFile)
//            let uploadTempFileURL = uploadTempDataDir.appendingPathComponent(uploadFile)
//            try move(from: uploadFileURL, to: uploadTempFileURL)
//            movedFiles += 1
//        }
//        
//        do {
//            return try FileManager.default.contentsOfDirectory(atPath: uploadTempDataDir.path)
//                .map {uploadDataDir.appendingPathComponent($0)}
//        } catch {
//            logger?.log("Failed to read contents of temp Upload Dir", logLevel: .error)
//            throw DataUploadError.DPErrorReadingContentsOfDir
//        }
//    }
//    
//    private func move(from srcURL: URL, to dstURL: URL) throws {
//        do {
//            try FileManager.default.moveItem(at: srcURL, to: dstURL)
//        } catch {
//            logger?.log(
//                "Failed to move source file: \(srcURL.lastPathComponent) to temp upload dir.",
//                logLevel: .error)
//            throw DataUploadError.DPErrorMovingDataFile
//        }
//    }
//    
//    private func removeAfterUpload(from URL: URL) {
//        do {
//            try remove(from: URL)
//        } catch {
//            var removalFailedFiles = (UserDefaults.standard.array(forKey: removalFailedFilesStoreKey) as? [URL]) ?? []
//            removalFailedFiles.append(URL)
//            UserDefaults.standard.setValue(removalFailedFiles, forKey: removalFailedFilesStoreKey)
//        }
//    }
//    
//    private func remove(from URL: URL) throws {
//        do {
//            try FileManager.default.removeItem(at: URL)
//        } catch {
//            logger?.log(
//                "Failed to remove source file: \(URL.lastPathComponent) from temp upload dir.",
//                logLevel: .error)
//            throw DataUploadError.DPErrorRemovingDataFile
//        }
//    }
//}

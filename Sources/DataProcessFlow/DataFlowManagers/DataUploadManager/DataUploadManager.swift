////
////  DataUploadManager.swift
////
////
////  Created by Azeem Muzammil on 2024-02-24.
////
//
//import Foundation
//
//class DataUploadManager {
//    private var isUploading = false
//    private var uploadTasks = [String : DataUploadTask]()
//    private let dataUploadGroup = DispatchGroup()
//    private let dataUploadQueue = DispatchQueue(label: "com.hopes.dataUploadQueue", qos: .background, attributes: .concurrent)
//    private let dataUploadSemaphore = DispatchSemaphore(value: 2)
//    private let tasksWriteQueue = DispatchQueue(label: "com.hopes.tasksWriteQueue", qos: .background)
//    
//    private init() { }
//    
//    // completion: DataUploadFinished(Sussessfully or Failed), Errors in DataCollection
//    func uploadData(completion: ((Bool, [Error]?) -> Void)? = nil) {
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            guard let self = self, !self.isUploading else {
//                completion?(false, nil)
//                return
//            }
//            
//            self.isUploading = true
//            
//            // Get files waiting for upload
//            let uploadDataStoreDir = DataStorageManager.getUploadDataDir()
//            var uploadErrors = [Error]()
//            do {
//                let files = try FileManager.default.contentsOfDirectory(atPath: uploadDataStoreDir.path)
//                for file in files {
//                    let filePath = uploadDataStoreDir.appendingPathComponent(file)
//                    self.dataUploadGroup.enter()
//                    self.dataUploadSemaphore.wait()
//                    let uploadTask = DataUploadTask(uploadFile: filePath, queue: dataUploadQueue) { uploadTaskRes in
//                        self.tasksWriteQueue.async {
//                            switch uploadTaskRes {
//                            case .SUCCESS:
//                                self.removeFile(filePath)
//                            case .FAILURE(let err):
//                                if let dataUPloadTaskErr = err as? DataUploadTaskError, dataUPloadTaskErr == .invalidFile {
//                                    self.removeFile(filePath)
//                                } else {
//                                    uploadErrors.append(err)
//                                }
//                            }
//                            self.dataUploadSemaphore.signal()
//                            self.dataUploadGroup.leave()
//                            self.uploadTasks.removeValue(forKey: filePath.lastPathComponent)
//                        }
//                    }
//                    tasksWriteQueue.sync {
//                        self.uploadTasks[filePath.lastPathComponent] = uploadTask
//                    }
//                    uploadTask.upload()
//                }
//                dataUploadGroup.notify(queue: .main) {
//                    self.isUploading = false
//                    completion?(true, uploadErrors.count == 0 ? nil : uploadErrors)
//                }
//            } catch (let err) {
//                isUploading = false
//                completion?(false, [err])
//            }
//        }
//    }
//    
//    func cancelUpload() {
//        guard isUploading else { return }
//        
//        for (_, uploadTask) in uploadTasks {
//            uploadTask.cancel()
//        }
//        isUploading = false
//    }
//    
//    private func removeFile(_ from: URL) {
//        do {
//            try FileManager.default.removeItem(at: from)
//        } catch {
//            // TODO: Handle Error.
//        }
//    }
//}

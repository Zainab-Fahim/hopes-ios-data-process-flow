////
////  DataUploadTask.swift
////
////
////  Created by Azeem Muzammil on 2024-02-24.
////
//
//import Foundation
//
//typealias DataUploadTaskResult = Result<Void, Error>
//
//class DataUploadTask {
//    private let networkService: NetworkService
//    private let dataFile: URL
//    private let onCompletion: (DataUploadTaskResult) -> Void
//    private let queue: DispatchQueue
//    private var uploadTask: URLSessionDataTask?
//    private var isCancelled = false
//
//    init(
//        networkService: NetworkService,
//        dataFile: URL,
//        queue: DispatchQueue,
//        onCompletion: @escaping (DataUploadTaskResult) -> Void)
//    {
//        self.networkService = networkService
//        self.dataFile = dataFile
//        self.onCompletion = onCompletion
//        self.queue = queue
//    }
//
//    func upload() {
//        queue.async { [unowned self] in
//            if !isCancelled {
//                networkService.uploadDataFile(dataFile) { result in
//                    switch result {
//                    case .success:
//                        self.onCompletion(.success(()))
//                    case .failure(let error):
//                        if (error as NSError).code == NSURLErrorCancelled {
//                            self.onCompletion(.failure(DataUploadError.DPErrorUploadCancelled))
//                        } else {
//                            self.onCompletion(.failure(error))
//                        }
//                    }
//                }
//            } else {
//                onCompletion(.failure(DataUploadError.DPErrorUploadCancelled))
//            }
//        }
//    }
//
//    func cancel() {
//        queue.async(flags: .barrier) { [unowned self] in
//            guard !isCancelled else { return }
//
//            uploadTask?.cancel()
//            isCancelled = true
//        }
//    }
//}

//
//  DataStoreError.swift
//
//
//  Created by Azeem Muzammil on 2024-02-17.
//

enum DataStoreError: ErrorRepresentable {
    // Data Directory Related Errors
    case DPErrorAccessingFileDir
    case DPErrorCreatingDataCollectionDir
    case DPErrorCreatingDataUploadDir
    case DPErrorReadingContentsOfDir
    case DPErrorInitializingDataStoreManager
    case DPErrorReadingFileAttributes
    // Data Encryption Related Errors
    case DPErrorReadingStoredChaChaKey
    case DPErrorCreatingRSAKeyRef
    case DPErrorEncryptingRSA
    case DPErrorEncryptingChaChaPoly
    case DPErrorEncodingStringToData
    // File Handle Related Errors
    case DPErrorInitializingFileHandle
    case DPErrorWritingDataToFile
    case DPErrorClosingFileHandle
    case DPErrorMovingFile
    case DPErrorDeletingFile
    case DPErrorFatal
    case DPErrorReadingFileContent
    case DPErrorValidatingEncryptionKey
}

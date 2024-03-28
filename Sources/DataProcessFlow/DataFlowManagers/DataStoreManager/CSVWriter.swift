//
//  CSVWriter.swift
//
//
//  Created by Azeem Muzammil on 2024-02-24.
//

import Foundation
import CryptoKit

class CSVWriter<T: DataStorable>: DataWriter {
    private let pemRSAPublicKey: String
    private let chaChaKey: SymmetricKey
    private let chaChaKeyStoreKey: String
    private let csvSeperator: String = ","
    private var headerWriteError: DataStoreError?

    init(
        logger: Logging?,
        dataFile: URL,
        isNewFile: Bool,
        fileSize: Int,
        pemRSAPublicKey: String
    ) throws {
        self.pemRSAPublicKey = pemRSAPublicKey
        self.chaChaKeyStoreKey = "com.moht.chaChaEncKeyFor\(T.source).\(dataFile.lastPathComponent)"
        if isNewFile {
            self.chaChaKey = SymmetricKey(size: .bits256)
        } else {
            do {
                let chaChaKeyData = try KeyStore.sharedInstance.getKeyData(for: chaChaKeyStoreKey)
                self.chaChaKey = SymmetricKey(data: chaChaKeyData)
            } catch {
                logger?.log("Failed to read stored ChaChaKey for datasource \"\(T.source)\".", logLevel: .error)
                throw DataStoreError.DPErrorReadingStoredChaChaKey
            }
        }

        super.init(logger: logger, dataFile: dataFile, fileSize: fileSize)

        if isNewFile {
            try writeDataEncKey()
            try writeDataHeader()
        }
    }

    func write(_ data: T?, isLast: Bool, completionHandler: @escaping (DataStoreError?) -> Void) -> Int {
        guard data?.dataRow.count == data?.numberOfFields else {
            logger?.log(
                "Fatal error occured for datasource \"\(T.source)\"." +
                " Data row count is higher than number of fields.",
                logLevel: .error)
            completionHandler(DataStoreError.DPErrorFatal)
            return 0
        }
        let dataRowString = (data?.dataRow.joined(separator: csvSeperator)).orEmpty
        do {
            let encryptedDataRow = try encrypt(dataRowString)
            writeData(encryptedDataRow, isLast: isLast) { [unowned self] error in
                completionHandler(error ?? headerWriteError)
            }
            return encryptedDataRow.count
        } catch {
            completionHandler((error as? DataStoreError))
            return 0
        }
    }

    override func endWriting() throws {
        guard let uploadDir = try DataStoreManager.sharedInstance?.getUploadDataDir() else {
            logger?.log(
                "Failed to initialize DataStoreManager for datasource \"\(String(describing: self))\".",
                logLevel: .error)
            throw DataStoreError.DPErrorInitializingDataStoreManager
        }
        do {
            // Check if the file is valid, if it's not valid, delete the file,
            // if it is valid, but not fully written not move. otherwise move.
            let validFile = try validateDataFile(dataFile)
            if validFile {
                do {
                    try FileManager.default.moveItem(
                        at: dataFile,
                        to: uploadDir.appendingPathComponent(dataFile.lastPathComponent))
                    try KeyStore.sharedInstance.deleteKeyData(for: chaChaKeyStoreKey)
                } catch {
                    logger?.log(
                        "Failed to move data file \(dataFile.lastPathComponent) for datasource " +
                        "\"\(String(describing: self))\".",
                        logLevel: .error)
                    throw DataStoreError.DPErrorMovingFile
                }
            }
        } catch {
            do {
                try FileManager.default.removeItem(at: dataFile)
                try KeyStore.sharedInstance.deleteKeyData(for: chaChaKeyStoreKey)
            } catch {
                logger?.log(
                    "Failed to delete data file \(dataFile.lastPathComponent) for datasource " +
                    "\"\(String(describing: self))\".",
                    logLevel: .error)
                throw DataStoreError.DPErrorDeletingFile
            }
        }
    }

    private func writeDataEncKey() throws {
        let chaChaKeyData = chaChaKey.withUnsafeBytes {
            return Data(Array($0))
        }
        let rsaPublicKey = pemRSAPublicKey
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\\n", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\r", with: "")

        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: 4096
        ]
        var error: Unmanaged<CFError>?

        guard let rsaPublicKeyData = Data(base64Encoded: rsaPublicKey),
              let rsaPublicKeyRef = SecKeyCreateWithData(
                rsaPublicKeyData as CFData,
                attributes as CFDictionary,
                &error) else {
            logger?.log(
                "Creating RSA public key ref for datasource \"\(T.source)\" " +
                "failed with error: \(String(describing: error))",
                logLevel: .error)
            throw DataStoreError.DPErrorCreatingRSAKeyRef
        }

        guard let chaChaEncryptedCFData = SecKeyCreateEncryptedData(
            rsaPublicKeyRef,
            .rsaEncryptionPKCS1,
            chaChaKeyData as CFData,
            &error) else {
            logger?.log(
                "Encrypting ChaCha key for datasource \"\(T.source)\" " +
                "failed with error: \(String(describing: error))",
                logLevel: .error)
            throw DataStoreError.DPErrorEncryptingRSA
        }

        try KeyStore.sharedInstance.storeKeyData(chaChaKeyData, for: chaChaKeyStoreKey)

        let chaChaEncryptedData = chaChaEncryptedCFData as Data
        let chaChaEncryptedB64Str = chaChaEncryptedData.base64EncodedString() + "\n"
        guard let chaChaEncryptedB64StrData = chaChaEncryptedB64Str.data(using: .utf8) else {
            logger?.log(
                "Encoding RSA encrypted string to data failed for datasource \"\(T.source)\".",
                logLevel: .error)
            throw DataStoreError.DPErrorEncodingStringToData
        }
        writeData(chaChaEncryptedB64StrData, isLast: false) { [unowned self] error in
            headerWriteError = error
        }
    }

    private func writeDataHeader() throws {
        let headerString = T.headers.joined(separator: csvSeperator)
        let encryptedHeader = try encrypt(headerString)
        writeData(encryptedHeader, isLast: false) { [unowned self] error in
            headerWriteError = error
        }
    }

    private func encrypt(_ str: String) throws -> Data {
        let nonce = ChaChaPoly.Nonce()
        let nonceData = nonce.withUnsafeBytes {
            Data(Array($0))
        }

        guard let strData = str.data(using: .utf8) else {
            logger?.log("Encoding string to data failed.", logLevel: .error)
            throw DataStoreError.DPErrorEncodingStringToData
        }
        do {
            let sealedBox = try ChaChaPoly.seal(strData, using: chaChaKey, nonce: nonce)
            let encryptedStr = "\(nonceData.base64EncodedString()):\(sealedBox.ciphertext.base64EncodedString())\n"
            guard let encryptedStrData = encryptedStr.data(using: .utf8) else {
                logger?.log("Encoding encrypted string to data failed.", logLevel: .error)
                throw DataStoreError.DPErrorEncodingStringToData
            }
            return encryptedStrData
        } catch {
            logger?.log("Encrypting string failed with error: \(error)", logLevel: .error)
            throw DataStoreError.DPErrorEncryptingChaChaPoly
        }
    }

    private func validateDataFile(_ fileURL: URL) throws -> Bool {
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            if lines.count == 0 {
                return false
            }
            if lines.count < 3 {
                let firstLine = lines[0]
                if isValidEncKey(firstLine) {
                    return false
                } else {
                    throw DataStoreError.DPErrorValidatingEncryptionKey
                }
            }
            let firstLine = lines[0]
            if isValidEncKey(firstLine) {
                return true
            } else {
                throw DataStoreError.DPErrorValidatingEncryptionKey
            }
        } catch {
            throw DataStoreError.DPErrorReadingFileContent
        }
    }

    private func isValidEncKey(_ str: String) -> Bool {
        if let base64Data = str.data(using: .utf8), let data = Data(base64Encoded: base64Data), data.count == 512 {
            return true
        }
        return false
    }
}

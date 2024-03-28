//
//  KeyStore.swift
//
//
//  Created by Azeem Muzammil on 2024-03-24.
//

import CryptoKit
import Foundation
import Valet

class KeyStore {
    static let sharedInstance = KeyStore()

    private let valet: Valet

    private init() {
        let identifier = Identifier(nonEmpty: "com.moht.hopesIOSDataProcessFlow.KeyStore")
        valet = Valet.valet(with: identifier!, accessibility: .afterFirstUnlock)
    }

    func getKeyData(for key: String) throws -> Data {
        do {
            return try valet.object(forKey: key)
        } catch {
            throw KeyStoreError.DPErrorReadingKeyData
        }
    }

    func storeKeyData(_ data: Data, for key: String) throws {
        do {
            try valet.setObject(data, forKey: key)
        } catch {
            throw KeyStoreError.DPErrorStoringKeyData
        }
    }

    func deleteKeyData(for key: String) throws {
        do {
            try valet.removeObject(forKey: key)
        } catch {
            throw KeyStoreError.DPErrorDeletingKeyData
        }
    }
}

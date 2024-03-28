//
//  KeyStoreError.swift
//  
//
//  Created by Azeem Muzammil on 2024-03-24.
//

enum KeyStoreError: ErrorRepresentable {
    case DPErrorReadingKeyData
    case DPErrorStoringKeyData
    case DPErrorDeletingKeyData
}

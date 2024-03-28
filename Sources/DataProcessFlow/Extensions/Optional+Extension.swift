//
//  Optional+Extension.swift
//
//
//  Created by Azeem Muzammil on 2024-02-19.
//

extension Optional where Wrapped == Int {
    var orZero: Int {
        return self ?? 0
    }
}

extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? ""
    }
}

//
//  DataStorable.swift
//
//
//  Created by Azeem Muzammil on 2024-02-04.
//

protocol DataStorable {
    static var source: DataSource { get }
    static var headers: [String] { get }
}

extension DataStorable {
    var dataRow: [String] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap { _, value in
            if let strConvertibleValue = value as? CustomStringConvertible {
                return strConvertibleValue.description
            }
            return ""
        }
    }

    var numberOfFields: Int {
        let mirror = Mirror(reflecting: self)
        return mirror.children.count
    }
}

//
//  NetworkService.swift
//
//
//  Created by Azeem Muzammil on 2024-02-25.
//

import Foundation

public protocol NetworkService {
    func uploadDataFile(_ url: URL, completionHandler: @escaping (Result<Void, Error>) -> Void)
}

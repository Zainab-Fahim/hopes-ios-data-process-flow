//
//  DataSourceDelegate.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import SensorKit

protocol DataSourceDelegate: AnyObject {
    func dataSource(_ dataSource: DataSource, didCompleteFetch fetchRequest: SRFetchRequest?)
    func dataSource(_ dataSource: DataSource, fetching fetchRequest: SRFetchRequest?, failedWithError error: Error)
}

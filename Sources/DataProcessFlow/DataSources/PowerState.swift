////
////  PowerState.swift
////
////
////  Created by Azeem Muzammil on 2024-02-14.
////
//
//import Foundation
//import UIKit
//
//class PowerState: NSObject, DataSourceable {
//    private var collectionRunning = false
//    private var dataStore: DataStore<PowerStateData>?
//    private var timer: Timer?
//    private let logger: Logger?
//    private let collectionTimeInterval: Double
//    
//    weak var delegate: DataSourceDelegate?
//
//    var lastReadingEndTime: Double = UserDefaults.standard.double(
//        forKey: Constants.UserDefaultKeys.powerStateLastReadingEndTimeKey)
//    var timeOffset: Double
//    
//    init(logger: Logger? = nil, collectionTimeInterval: Double) {
//        self.logger = logger
//        self.collectionTimeInterval = collectionTimeInterval
//        self.timeOffset = 0
//
//        super.init()
//    }
//    
//    func isAvailable() -> Bool {
//        return true
//    }
//    
//    func startReading() {
//        dataStore = DataStoreManager.sharedInstance?.getDataStore()
//        
//        startPSServices()
//    }
//    
//    func endReading() {
//        stopPSServices()
//        dataStore?.close()
//    }
//    
//    private func startPSServices() {
//        guard !collectionRunning else { return }
//        collectionRunning = true
//        
//        // Schedule Collection
//        timer = Timer.scheduledTimer(withTimeInterval: collectionTimeInterval, repeats: false) { _ in
//            self.endReading()
//        }
//        
//        // Write current PS data
//        writePSData()
//        // Listen to upcoming PS data
//        UIDevice.current.isBatteryMonitoringEnabled = true
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.batteryStateDidChange),
//            name: UIDevice.batteryStateDidChangeNotification,
//            object: nil)
//    }
//    
//    private func stopPSServices() {
//        guard collectionRunning else { return }
//        collectionRunning = false
//        
//        // Invalidate Timer
//        timer?.invalidate()
//        
//        UIDevice.current.isBatteryMonitoringEnabled = false
//        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object:nil)
//        
//        logger?.log("PowerState Data Reading Completed.", logLevel: .info)
//        delegate?.dataSource(.powerState, didCompleteFetch: nil)
//    }
//    
//    private func writePSData() {
//        guard let dataStore else {
//            logger?.log("Failed to Read PowerState Data. DataStore Initialization Failed.", logLevel: .error)
//            return
//        }
//        let currentTimestamp: Double = DateUtil().getCurrentTimestamp(to: .SECOND)
//        var state: String
//        switch(UIDevice.current.batteryState) {
//        case .charging:
//            state = "Power is connected"
//        case .full:
//            state = "Battery is full"
//        case .unplugged:
//            state = "Power is disconnected"
//        default:
//            state = "Power is unknown"
//        }
//        let data = PowerStateData(
//            timestamp: Int64(currentTimestamp * 1000),
//            event: state,
//            level: UIDevice.current.batteryLevel,
//            tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//        
//        dataStore.store(data)
//        UserDefaults.standard.setValue(
//            currentTimestamp,
//            forKey: Constants.UserDefaultKeys.powerStateLastReadingEndTimeKey)
//    }
//    
//    @objc private func batteryStateDidChange(_ notification: Notification) {
//        writePSData()
//    }
//}

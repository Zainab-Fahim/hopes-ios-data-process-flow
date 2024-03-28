////
////  SKDataSource.swift
////
////
////  Created by Azeem Muzammil on 2024-02-15.
////
//
//import SensorKit
//
//class SKDataSource<T: DataStorable>: DataSourceable {
//    private let currentTimestamp: Double
//    private let deviceSpecificTimestamp: Double
//    private var sourceName: String
//    private let logger: Logger?
//    private let dataSourceDevice: DataSourceDevice
//    private var dataStore: DataStore<T>?
//    private let sensorReader: SRSensorReader
//    private var continueReading: Bool = true
//
//    var lastReadingEndTime: Double
//    var timeOffset: Double
//
//    init(logger: Logger? = nil, dataSourceDevice: DataSourceDevice, sensorReader: SRSensorReader, lastReadingEndTime: Double) {
//        self.currentTimestamp = DateUtil().getCurrentTimestamp(to: .SECOND)
//        self.deviceSpecificTimestamp = SRAbsoluteTime.current().rawValue
//        self.sourceName = String(describing: type(of: self))
//        self.logger = logger
//        self.dataSourceDevice = dataSourceDevice
//        self.sensorReader = sensorReader
//        self.lastReadingEndTime = lastReadingEndTime
//        self.timeOffset = currentTimestamp - deviceSpecificTimestamp
//    }
//
//    func isAvailable() -> Bool {
//        guard sensorReader.authorizationStatus == .authorized else {
//            logger?.log(
//                "\(sourceName) Data Collection is not Authorized. Not Initializing Collection.",
//                logLevel: .warning)
//            return false
//        }
//
//        return true
//    }
//
//    func startReading() {
//        continueReading = true
//        dataStore = DataStoreManager.sharedInstance?.getDataStore()
//
//        sensorReader.startRecording()
//        sensorReader.fetchDevices()
//    }
//    
//    func endReading() {
//        continueReading = false
//        dataStore?.close()
//    }
//    
//    func fetchData(for devices: [SRDevice]) {
//        switch dataSourceDevice {
//        case .all:
//            devices.forEach { device in
//                fetchData(for: device)
//            }
//        case .current:
//            devices.forEach { device in
//                if device == SRDevice.current {
//                    fetchData(for: device)
//                }
//            }
//        }
//    }
//    
//    private func fetchData(for device: SRDevice) {
//        let before24HrsTime = deviceSpecificTimestamp - Double(Constants.Time.oneDay)
//
//        let fetchRequest = SRFetchRequest()
//        fetchRequest.from = SRAbsoluteTime(lastReadingEndTime)
//        fetchRequest.to = SRAbsoluteTime(before24HrsTime)
//        fetchRequest.device = device
//        sensorReader.fetch(fetchRequest)
//    }
//}

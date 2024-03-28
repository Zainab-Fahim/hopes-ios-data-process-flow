////
////  DeviceUsageReport.swift
////
////
////  Created by Azeem Muzammil on 2024-02-14.
////
//
//import SensorKit
//
//class DeviceUsageReport: NSObject, DataSourceable {
//    private var dataStore: DataStore<DeviceUsageReportData>?
//    private let logger: Logger?
//    private let dataSourceDevice: DataSourceDevice
//    private let currentTimestamp: Double
//    private let deviceSpecificTimestamp: Double
//    private var continueReading: Bool = true
//    private let sensorReader: SRSensorReader = SRSensorReader(sensor: .deviceUsageReport)
//    
//    weak var delegate: DataSourceDelegate?
//
//    var lastReadingEndTime: Double = UserDefaults.standard.double(
//        forKey: Constants.UserDefaultKeys.deviceUsageReportLastReadingEndTimeKey)
//    var timeOffset: Double
//    
//    init(logger: Logger? = nil, dataSourceDevice: DataSourceDevice) {
//        self.logger = logger
//        self.dataSourceDevice = dataSourceDevice
//        self.currentTimestamp = DateUtil().getCurrentTimestamp(to: .SECOND)
//        self.deviceSpecificTimestamp = SRAbsoluteTime.current().rawValue
//        self.timeOffset = currentTimestamp - deviceSpecificTimestamp
//
//        super.init()
//    }
//    
//    func isAvailable() -> Bool {
//        guard sensorReader.authorizationStatus == .authorized else {
//            logger?.log(
//                "DeviceUsageReport Data Collection is not Authorized. Not Initializing Collection.",
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
//        sensorReader.delegate = self
//        sensorReader.startRecording()
//        sensorReader.fetchDevices()
//    }
//    
//    func endReading() {
//        continueReading = false
//        dataStore?.close()
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
//
//// MARK: - Delegate Methods for SRSensorReader
//extension DeviceUsageReport: SRSensorReaderDelegate {
//    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
//        logger?.log("DeviceUsageReport Data Collection is Initialized.", logLevel: .info)
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
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
//    func sensorReader(
//        _ reader: SRSensorReader,
//        fetching fetchRequest: SRFetchRequest,
//        didFetchResult result: SRFetchResult<AnyObject>
//    ) -> Bool {
//        guard let dataStore else {
//            logger?.log("Failed to Read DeviceUsageReport Data. DataStore Initialization Failed.", logLevel: .error)
//            return false
//        }
//        guard continueReading else {
//            return false
//        }
//        guard let sample = result.sample as? SRDeviceUsageReport else {
//            logger?.log("Failed to Cast DeviceUsageReport Data Sample.", logLevel: .error)
//            return false
//        }
//        let resultDeviceSpecificTimestamp = result.timestamp.rawValue
//        let resultTimestamp: Double = resultDeviceSpecificTimestamp + timeOffset
//        
//        let applicationUsage: [SRDeviceUsageReport.CategoryKey: [SRDeviceUsageReport.ApplicationUsage]] = sample.applicationUsageByCategory
//        let notificationUsage: [SRDeviceUsageReport.CategoryKey: [SRDeviceUsageReport.NotificationUsage]] = sample.notificationUsageByCategory
//        
//        for (appCategory, appUsages) in applicationUsage {
//            appUsages.forEach { appUsage in
//                if #available(iOS 15.0, *) {
//                    appUsage.textInputSessions.forEach { textInputSession in
//                        let data = DeviceUsageReportData(
//                            timestamp: Int64(resultTimestamp * 1000),
//                            reportDuration: sample.duration,
//                            totalScreenWakes: sample.totalScreenWakes,
//                            totalUnlocks: sample.totalUnlocks,
//                            totalUnlockDuration: sample.totalUnlockDuration,
//                            appCategory: appCategory.rawValue,
//                            appBundleId: appUsage.bundleIdentifier ?? appUsage.reportApplicationIdentifier,
//                            appUsageTime: appUsage.usageTime,
//                            appTextInputSessionDuration: textInputSession.duration,
//                            appTextInputSessionType: textInputSession.sessionType.rawValue,
//                            notificationCategory: nil,
//                            notificationBundleId: nil,
//                            notificationEvent: nil,
//                            tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//                        dataStore.store(data)
//                        UserDefaults.standard.setValue(
//                            resultDeviceSpecificTimestamp,
//                            forKey: Constants.UserDefaultKeys.deviceUsageReportLastReadingEndTimeKey)
//                    }
//                } else {
//                    let data = DeviceUsageReportData(
//                        timestamp: Int64(resultTimestamp * 1000),
//                        reportDuration: sample.duration,
//                        totalScreenWakes: sample.totalScreenWakes,
//                        totalUnlocks: sample.totalUnlocks,
//                        totalUnlockDuration: sample.totalUnlockDuration,
//                        appCategory: appCategory.rawValue,
//                        appBundleId: appUsage.bundleIdentifier,
//                        appUsageTime: appUsage.usageTime,
//                        appTextInputSessionDuration: nil,
//                        appTextInputSessionType: nil,
//                        notificationCategory: nil,
//                        notificationBundleId: nil,
//                        notificationEvent: nil,
//                        tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//                    dataStore.store(data)
//                    UserDefaults.standard.setValue(
//                        resultDeviceSpecificTimestamp,
//                        forKey: Constants.UserDefaultKeys.deviceUsageReportLastReadingEndTimeKey)
//                }
//            }
//        }
//        
//        for (notiCategory, notiUsages) in notificationUsage {
//            notiUsages.forEach { notiUsage in
//                let data = DeviceUsageReportData(
//                    timestamp: Int64(resultTimestamp * 1000),
//                    reportDuration: sample.duration,
//                    totalScreenWakes: sample.totalScreenWakes,
//                    totalUnlocks: sample.totalUnlocks,
//                    totalUnlockDuration: sample.totalUnlockDuration,
//                    appCategory: nil,
//                    appBundleId: nil,
//                    appUsageTime: nil,
//                    appTextInputSessionDuration: nil,
//                    appTextInputSessionType: nil,
//                    notificationCategory: notiCategory.rawValue,
//                    notificationBundleId: notiUsage.bundleIdentifier,
//                    notificationEvent: notiUsage.event.rawValue,
//                    tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//                dataStore.store(data)
//                UserDefaults.standard.setValue(
//                    resultDeviceSpecificTimestamp,
//                    forKey: Constants.UserDefaultKeys.deviceUsageReportLastReadingEndTimeKey)
//            }
//        }
//        return true
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
//        logger?.log("DeviceUsageReport Data Reading Completed.", logLevel: .info)
//        delegate?.dataSource(.deviceUsageReport, didCompleteFetch: fetchRequest)
//    }
//
//    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
//        logger?.log("DeviceUsageReport Data Reading Completed with Error: \(error)", logLevel: .error)
//        delegate?.dataSource(.deviceUsageReport, fetching: fetchRequest, failedWithError: error)
//    }
//}

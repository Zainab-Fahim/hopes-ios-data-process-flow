////
////  RotationRate.swift
////
////
////  Created by Azeem Muzammil on 2024-02-14.
////
//
//import SensorKit
//import CoreMotion
//
//class RotationRate: NSObject, DataSourceable {
//    private var lastSampleTimestamp: Double?
//    private var dataStore: DataStore<RotationRateData>?
//    private let logger: Logger?
//    private let dataSourceDevice: DataSourceDevice
//    private let sampleFrequency: Double
//    private let currentTimestamp: Double
//    private let deviceSpecificTimestamp: Double
//    private var continueReading: Bool = true
//    private let sensorReader: SRSensorReader = SRSensorReader(sensor: .rotationRate)
//    
//    weak var delegate: DataSourceDelegate?
//
//    var lastReadingEndTime: Double = UserDefaults.standard.double(
//        forKey: Constants.UserDefaultKeys.rotationRateLastReadingEndTimeKey)
//    var timeOffset: Double
//    
//    init(logger: Logger? = nil, dataSourceDevice: DataSourceDevice, sampleFrequency: Double) {
//        self.logger = logger
//        self.dataSourceDevice = dataSourceDevice
//        self.sampleFrequency = sampleFrequency
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
//                "RotationRate Data Collection is not Authorized. Not Initializing Collection.",
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
//extension RotationRate: SRSensorReaderDelegate {
//    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
//        logger?.log("RotationRate Data Collection is Initialized.", logLevel: .info)
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
//            logger?.log("Failed to Read RotationRate Data. DataStore Initialization Failed.", logLevel: .error)
//            return false
//        }
//        guard continueReading else {
//            return false
//        }
//        guard let sampleList = result.sample as? [CMRecordedRotationRateData] else {
//            logger?.log("Failed to Cast RotationRate Data Sample.", logLevel: .error)
//            return false
//        }
//        let resultDeviceSpecificTimestamp = result.timestamp.rawValue
//        let resultTimestamp: Double = resultDeviceSpecificTimestamp + timeOffset
//        let sample = sampleList.first
//
//        if let sample, lastSampleTimestamp == nil || resultTimestamp - lastSampleTimestamp! >= sampleFrequency {
//            let data = RotationRateData(
//                timestamp: Int64(resultTimestamp * 1000),
//                x: sample.rotationRate.x,
//                y: sample.rotationRate.y,
//                z: sample.rotationRate.z,
//                tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//
//            dataStore.store(data)
//            UserDefaults.standard.setValue(
//                resultDeviceSpecificTimestamp,
//                forKey: Constants.UserDefaultKeys.rotationRateLastReadingEndTimeKey)
//            lastSampleTimestamp = resultTimestamp
//        }
//        return true
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
//        logger?.log("RotationRate Data Reading Completed.", logLevel: .info)
//        delegate?.dataSource(.rotationRate, didCompleteFetch: fetchRequest)
//    }
//
//    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
//        logger?.log("RotationRate Data Reading Completed with Error: \(error)", logLevel: .error)
//        delegate?.dataSource(.rotationRate, fetching: fetchRequest, failedWithError: error)
//    }
//}

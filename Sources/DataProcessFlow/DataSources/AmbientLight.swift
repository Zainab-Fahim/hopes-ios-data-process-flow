////
////  AmbientLight.swift
////
////
////  Created by Azeem Muzammil on 2024-02-14.
////
//
//import SensorKit
//
//class AmbientLight: NSObject, DataSourceable {
//    private var lastSampleTimestamp: Double?
//    private var dataStore: DataStore<AmbientLightData>?
//    private let logger: Logger?
//    private let dataSourceDevice: DataSourceDevice
//    private let sampleFrequency: Double
//    private let currentTimestamp: Double
//    private let deviceSpecificTimestamp: Double
//    private var continueReading: Bool = true
//    private let sensorReader: SRSensorReader = SRSensorReader(sensor: .ambientLightSensor)
//    
//    weak var delegate: DataSourceDelegate?
//
//    var lastReadingEndTime: Double = UserDefaults.standard.double(
//        forKey: Constants.UserDefaultKeys.ambientLightLastReadingEndTimeKey)
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
//                "AmbientLight Data Collection is not Authorized. Not Initializing Collection.",
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
//extension AmbientLight: SRSensorReaderDelegate {
//    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
//        logger?.log("AmbientLight Data Collection is Initialized.", logLevel: .info)
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
//            logger?.log("Failed to Read AmbientLight Data. DataStore Initialization Failed.", logLevel: .error)
//            return false
//        }
//        guard continueReading else {
//            return false
//        }
//        guard let sample = result.sample as? SRAmbientLightSample else {
//            logger?.log("Failed to Cast AmbientLight Data Sample.", logLevel: .error)
//            return false
//        }
//        let resultDeviceSpecificTimestamp = result.timestamp.rawValue
//        let resultTimestamp: Double = resultDeviceSpecificTimestamp + timeOffset
//
//        if (lastSampleTimestamp == nil || resultTimestamp - lastSampleTimestamp! >= sampleFrequency) {
//            let data = AmbientLightData(
//                timestamp: Int64(resultTimestamp * 1000),
//                chromaticityX: sample.chromaticity.x,
//                chromaticityY: sample.chromaticity.y,
//                lux: sample.lux.value,
//                tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//
//            dataStore.store(data)
//            UserDefaults.standard.setValue(
//                resultDeviceSpecificTimestamp,
//                forKey: Constants.UserDefaultKeys.ambientLightLastReadingEndTimeKey)
//            lastSampleTimestamp = resultTimestamp
//        }
//        return true
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
//        logger?.log("AmbientLight Data Reading Completed.", logLevel: .info)
//        delegate?.dataSource(.ambientLight, didCompleteFetch: fetchRequest)
//    }
//
//    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
//        logger?.log("AmbientLight Data Reading Completed with Error: \(error)", logLevel: .error)
//        delegate?.dataSource(.ambientLight, fetching: fetchRequest, failedWithError: error)
//    }
//}

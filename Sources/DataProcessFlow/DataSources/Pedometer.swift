////
////  Pedometer.swift
////
////
////  Created by Azeem Muzammil on 2024-02-14.
////
//
//import SensorKit
//import CoreMotion
//
//class Pedometer: NSObject, DataSourceable {
//    private var dataStore: DataStore<PedometerData>?
//    private let logger: Logger?
//    private let dataSourceDevice: DataSourceDevice
//    private let currentTimestamp: Double
//    private let deviceSpecificTimestamp: Double
//    private var continueReading: Bool = true
//    private let sensorReader: SRSensorReader = SRSensorReader(sensor: .pedometerData)
//    
//    weak var delegate: DataSourceDelegate?
//
//    var lastReadingEndTime: Double = UserDefaults.standard.double(
//        forKey: Constants.UserDefaultKeys.pedometerLastReadingEndTimeKey)
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
//                "Pedometer Data Collection is not Authorized. Not Initializing Collection.",
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
//extension Pedometer: SRSensorReaderDelegate {
//    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
//        logger?.log("Pedometer Data Collection is Initialized.", logLevel: .info)
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
//            logger?.log("Failed to Read Pedometer Data. DataStore Initialization Failed.", logLevel: .error)
//            return false
//        }
//        guard continueReading else {
//            return false
//        }
//        guard let sample = result.sample as? CMPedometerData else {
//            logger?.log("Failed to Cast Pedometer Data Sample.", logLevel: .error)
//            return false
//        }
//        let resultDeviceSpecificTimestamp = result.timestamp.rawValue
//        let resultTimestamp: Double = resultDeviceSpecificTimestamp + timeOffset
//
//        let data = PedometerData(
//            timestamp: Int64(resultTimestamp * 1000),
//            averageActivePace: sample.averageActivePace,
//            currentCadence: sample.currentCadence,
//            currentPace: sample.currentPace,
//            distance: sample.distance,
//            startDate: sample.startDate,
//            endDate: sample.endDate,
//            floorsAscended: sample.floorsAscended,
//            floorsDescended: sample.floorsDescended,
//            steps: sample.numberOfSteps,
//            tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//
//        dataStore.store(data)
//        UserDefaults.standard.setValue(
//            resultDeviceSpecificTimestamp,
//            forKey: Constants.UserDefaultKeys.pedometerLastReadingEndTimeKey)
//        return true
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
//        logger?.log("Pedometer Data Reading Completed.", logLevel: .info)
//        delegate?.dataSource(.pedometer, didCompleteFetch: fetchRequest)
//    }
//
//    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
//        logger?.log("Pedometer Data Reading Completed with Error: \(error)", logLevel: .error)
//        delegate?.dataSource(.pedometer, fetching: fetchRequest, failedWithError: error)
//    }
//}

////
////  KeyboardMetrics.swift
////
////
////  Created by Azeem Muzammil on 2024-02-14.
////
//
//import SensorKit
//
//class KeyboardMetrics: NSObject, DataSourceable {
//    private var dataStore: DataStore<KeyboardMetricsData>?
//    private let logger: Logger?
//    private let dataSourceDevice: DataSourceDevice
//    private let currentTimestamp: Double
//    private let deviceSpecificTimestamp: Double
//    private var continueReading: Bool = true
//    private let sensorReader: SRSensorReader = SRSensorReader(sensor: .keyboardMetrics)
//    
//    weak var delegate: DataSourceDelegate?
//
//    var lastReadingEndTime: Double = UserDefaults.standard.double(
//        forKey: Constants.UserDefaultKeys.keyboardMetricsLastReadingEndTimeKey)
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
//                "KeyboardMetrics Data Collection is not Authorized. Not Initializing Collection.",
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
//extension KeyboardMetrics: SRSensorReaderDelegate {
//    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
//        logger?.log("KeyboardMetrics Data Collection is Initialized.", logLevel: .info)
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
//            logger?.log("Failed to Read KeyboardMetrics Data. DataStore Initialization Failed.", logLevel: .error)
//            return false
//        }
//        guard continueReading else {
//            return false
//        }
//        guard let sample = result.sample as? SRKeyboardMetrics else {
//            logger?.log("Failed to Cast KeyboardMetrics Data Sample.", logLevel: .error)
//            return false
//        }
//        let resultDeviceSpecificTimestamp = result.timestamp.rawValue
//        let resultTimestamp: Double = resultDeviceSpecificTimestamp + timeOffset
//        
//        let data: KeyboardMetricsData!
//        if #available(iOS 15.0, *) {
//            data = KeyboardMetricsData(
//                timestamp: Int64(resultTimestamp * 1000),
//                usageDuration: sample.totalTypingDuration,
//                inputModes: sample.inputModes,
//                noOfAlteredWordes: sample.totalAlteredWords,
//                noOfAutoCorrections: sample.totalAutoCorrections,
//                noOfDeletes: sample.totalDeletes,
//                noOfDrags: sample.totalDrags,
//                noOfEmojis: sample.totalEmojis,
//                noOfWordTyped: sample.totalWords,
//                noOfAbsolutistEmojis: sample.emojiCount(for: .absolutist),
//                noOfAbsolutistWords: sample.wordCount(for: .absolutist),
//                noOfAngerEmojis: sample.emojiCount(for: .anger),
//                noOfAngerRelatedWords: sample.wordCount(for: .anger),
//                noOfAnxietyEmojis: sample.emojiCount(for: .anxiety),
//                noOfAnxietyRelatedWords: sample.wordCount(for: .anxiety),
//                noOfConfusedEmojis: sample.emojiCount(for: .confused),
//                noOfConfusedRelatedWords: sample.wordCount(for: .confused),
//                noOfDeathEmojis: sample.emojiCount(for: .death),
//                noOfDeathRelatedWords: sample.wordCount(for: .death),
//                noOfDownEmojis: sample.emojiCount(for: .down),
//                noOfDownRelatedWords: sample.wordCount(for: .down),
//                noOfHealthFeelingEmojis: sample.emojiCount(for: .health),
//                noOfHealthFeelingRelatedWords: sample.wordCount(for: .health),
//                noOfLowEnergyEmojis: sample.emojiCount(for: .lowEnergy),
//                noOfLowEnergyRelatedWords: sample.wordCount(for: .lowEnergy),
//                noOfPositiveEmojis: sample.emojiCount(for: .positive),
//                noOfPositiveRelatedWords: sample.wordCount(for: .positive),
//                noOfSadEmojis: sample.emojiCount(for: .sad),
//                noOfSadRelatedWords: sample.wordCount(for: .sad),
//                typingTime: sample.totalTypingDuration,
//                tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//        } else {
//            data = KeyboardMetricsData(
//                timestamp: Int64(resultTimestamp * 1000),
//                usageDuration: sample.totalTypingDuration,
//                inputModes: nil,
//                noOfAlteredWordes: sample.totalAlteredWords,
//                noOfAutoCorrections: sample.totalAutoCorrections,
//                noOfDeletes: sample.totalDeletes,
//                noOfDrags: sample.totalDrags,
//                noOfEmojis: sample.totalEmojis,
//                noOfWordTyped: sample.totalWords,
//                noOfAbsolutistEmojis: nil,
//                noOfAbsolutistWords: nil,
//                noOfAngerEmojis: nil,
//                noOfAngerRelatedWords: nil,
//                noOfAnxietyEmojis: nil,
//                noOfAnxietyRelatedWords: nil,
//                noOfConfusedEmojis: nil,
//                noOfConfusedRelatedWords: nil,
//                noOfDeathEmojis: nil,
//                noOfDeathRelatedWords: nil,
//                noOfDownEmojis: nil,
//                noOfDownRelatedWords: nil,
//                noOfHealthFeelingEmojis: nil,
//                noOfHealthFeelingRelatedWords: nil,
//                noOfLowEnergyEmojis: nil,
//                noOfLowEnergyRelatedWords: nil,
//                noOfPositiveEmojis: nil,
//                noOfPositiveRelatedWords: nil,
//                noOfSadEmojis: nil,
//                noOfSadRelatedWords: nil,
//                typingTime: sample.totalTypingDuration,
//                tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//        }
//        
//        dataStore.store(data)
//        UserDefaults.standard.setValue(
//            resultDeviceSpecificTimestamp,
//            forKey: Constants.UserDefaultKeys.keyboardMetricsLastReadingEndTimeKey)
//        return true
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
//        logger?.log("KeyboardMetrics Data Reading Completed.", logLevel: .info)
//        delegate?.dataSource(.keyboardMetrics, didCompleteFetch: fetchRequest)
//    }
//
//    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
//        logger?.log("KeyboardMetrics Data Reading Completed with Error: \(error)", logLevel: .error)
//        delegate?.dataSource(.keyboardMetrics, fetching: fetchRequest, failedWithError: error)
//    }
//}

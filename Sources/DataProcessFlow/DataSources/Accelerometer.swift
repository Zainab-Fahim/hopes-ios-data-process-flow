//
//  Accelerometer.swift
//
//
//  Created by Azeem Muzammil on 2024-02-05.
//

import SensorKit
import CoreMotion

public class Accelerometer: NSObject, DataSourceable {
    private var lastSampleTimestamp: Double?
    private var dataStore: DataStore<AccelerometerData>?
    private let logger: Logging?
    private let dataSourceDevice: DataSourceDevice
    private let sampleFrequency: Double
    private let currentTimestamp: Double
    private let deviceSpecificTimestamp: Double
    private let gravityAccel: Double = 9.81
    private var continueReading: Bool = true
    private let sensorReader: SRSensorReader = SRSensorReader(sensor: .accelerometer)

    weak var delegate: DataSourceDelegate?

    var lastReadingEndTime: Double = UserDefaults.standard.double(
        forKey: Constants.UserDefaultKeys.accelerometerLastReadingEndTimeKey)
    var timeOffset: Double

    init(logger: Logging?, dataSourceDevice: DataSourceDevice, sampleFrequency: Double) {
        self.logger = logger
        self.dataSourceDevice = dataSourceDevice
        self.sampleFrequency = sampleFrequency
        self.currentTimestamp = DateUtil().getCurrentTimestamp(to: .SECOND)
        self.deviceSpecificTimestamp = SRAbsoluteTime.current().rawValue
        self.timeOffset = currentTimestamp - deviceSpecificTimestamp

        super.init()
    }

    func isAvailable() -> Bool {
        guard sensorReader.authorizationStatus == .authorized else {
            logger?.log(
                "Accelerometer Data Collection is not Authorized. Not Initializing Collection.",
                logLevel: .warning)
            return false
        }

        return true
    }

    func startReading() {
        continueReading = true
        dataStore = DataStoreManager.sharedInstance?.getDataStore()

        sensorReader.delegate = self
        sensorReader.startRecording()
        sensorReader.fetchDevices()
    }

    func endReading() {
        continueReading = false
        dataStore?.close { _ in
            print("Data Store Closed")
        }
    }

    private func fetchData(for device: SRDevice) {
        let before24HrsTime = deviceSpecificTimestamp - Double(Constants.Time.oneDay)

        let fetchRequest = SRFetchRequest()
        fetchRequest.from = SRAbsoluteTime(lastReadingEndTime)
        fetchRequest.to = SRAbsoluteTime(before24HrsTime)
        fetchRequest.device = device
        sensorReader.fetch(fetchRequest)
    }
}

// MARK: - Delegate Methods for SRSensorReader
extension Accelerometer: SRSensorReaderDelegate {
    public func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        logger?.log("Accelerometer Data Collection is Initialized.", logLevel: .info)
    }

    public func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        switch dataSourceDevice {
        case .all:
            devices.forEach { device in
                fetchData(for: device)
            }
        case .current:
            devices.forEach { device in
                if device == SRDevice.current {
                    fetchData(for: device)
                }
            }
        }
    }

    public func sensorReader(
        _ reader: SRSensorReader,
        fetching fetchRequest: SRFetchRequest,
        didFetchResult result: SRFetchResult<AnyObject>
    ) -> Bool {
        guard let dataStore else {
            logger?.log("Failed to Read Accelerometer Data. DataStore Initialization Failed.", logLevel: .error)
            return false
        }
        guard continueReading else {
            return false
        }
        guard let sampleList = result.sample as? [CMRecordedAccelerometerData] else {
            logger?.log("Failed to Cast Accelerometer Data Sample.", logLevel: .error)
            return false
        }
        let resultDeviceSpecificTimestamp = result.timestamp.rawValue
        let resultTimestamp: Double = resultDeviceSpecificTimestamp + timeOffset
        let sample = sampleList.first

        if let sample, lastSampleTimestamp == nil || resultTimestamp - lastSampleTimestamp! >= sampleFrequency {
            let data = AccelerometerData(
                timestamp: Int64(resultTimestamp * 1000),
                accuracy: nil,
                x: sample.acceleration.x * gravityAccel,
                y: sample.acceleration.y * gravityAccel,
                z: sample.acceleration.z * gravityAccel,
                tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())

            dataStore.store(data) { _ in
                print("Data Store stored data")
            }
            UserDefaults.standard.setValue(
                resultDeviceSpecificTimestamp,
                forKey: Constants.UserDefaultKeys.accelerometerLastReadingEndTimeKey)
            lastSampleTimestamp = resultTimestamp
        }
        return true
    }

    public func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        logger?.log("Accelerometer Data Reading Completed.", logLevel: .info)
        delegate?.dataSource(.accelerometer, didCompleteFetch: fetchRequest)
    }

    public func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        logger?.log("Accelerometer Data Reading Completed with Error: \(error)", logLevel: .error)
        delegate?.dataSource(.accelerometer, fetching: fetchRequest, failedWithError: error)
    }
}

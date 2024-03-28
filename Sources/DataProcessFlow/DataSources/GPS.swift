////
////  GPS.swift
////
////
////  Created by Azeem Muzammil on 2024-02-14.
////
//
//import CoreLocation
//
//class GPS: NSObject, DataSourceable {
//    private var collectionRunning = false
//    private let locationManager: CLLocationManager
//    private var lastSampleTimestamp: Double?
//    private var dataStore: DataStore<GPSData>?
//    private var timer: Timer?
//    private let logger: Logger?
//    private let noOfSamples: Int
//    private let sampleFrequency: Double
//    private let collectionTimeInterval: Double
//    private var fuzzLatitudeOffset: Double
//    private var fuzzLongitudeOffset: Double
//    private var fuzzAltitudeOffset: Double
//    private var noOfSamplesSoFar: Int {
//        didSet {
//            if noOfSamplesSoFar >= noOfSamples {
//                endReading()
//            }
//        }
//    }
//
//    weak var delegate: DataSourceDelegate?
//
//    var lastReadingEndTime: Double = UserDefaults.standard.double(
//        forKey: Constants.UserDefaultKeys.gpsLastReadingEndTimeKey)
//    var timeOffset: Double
//
//    init(
//        logger: Logger? = nil,
//        noOfSamples: Int,
//        sampleFrequency: Double,
//        collectionTimeInterval: Double,
//        fuzzLatitudeOffset: Double,
//        fuzzLongitudeOffset: Double,
//        fuzzAltitudeOffset: Double
//    ) {
//        self.locationManager = CLLocationManager()
//        self.logger = logger
//        self.noOfSamples = noOfSamples
//        self.sampleFrequency = sampleFrequency
//        self.collectionTimeInterval = collectionTimeInterval
//        self.fuzzLatitudeOffset = fuzzLatitudeOffset
//        self.fuzzLongitudeOffset = fuzzLongitudeOffset
//        self.fuzzAltitudeOffset = fuzzAltitudeOffset
//        self.noOfSamplesSoFar = 0
//        self.timeOffset = 0
//
//        super.init()
//    }
//
//    func isAvailable() -> Bool {
//        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
//                locationManager.authorizationStatus == .authorizedAlways else {
//            logger?.log(
//                "GPS Data Collection is not Authorized. Not Initializing Collection.",
//                logLevel: .warning)
//            return false
//        }
//
//        return true
//    }
//
//    func startReading() {
//        if !isAvailable() {
//            locationManager.requestAlwaysAuthorization()
//        } else {
//            dataStore = DataStoreManager.sharedInstance?.getDataStore()
//            startGPSServices()
//        }
//    }
//
//    func endReading() {
//        stopGPSServices()
//        noOfSamplesSoFar = 0
//        dataStore?.close()
//    }
//
//    private func startGPSServices() {
//        guard !collectionRunning else { return }
//        collectionRunning = true
//
//        // Schedule Collection
//        timer = Timer.scheduledTimer(withTimeInterval: collectionTimeInterval, repeats: false) { _ in
//            self.endReading()
//        }
//
//        locationManager.delegate = self
//        locationManager.activityType = .other
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.distanceFilter = kCLDistanceFilterNone
//        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.startMonitoringSignificantLocationChanges()
//    }
//
//    private func stopGPSServices() {
//        guard collectionRunning else { return }
//        collectionRunning = false
//
//        // Invalidate Timer
//        timer?.invalidate()
//
//        locationManager.delegate = nil
//        locationManager.stopUpdatingLocation()
//        locationManager.stopMonitoringSignificantLocationChanges()
//
//        logger?.log("GPS Data Reading Completed.", logLevel: .info)
//        delegate?.dataSource(.gps, didCompleteFetch: nil)
//    }
//}
//
//// MARK: - Delegate Methods for CLLocationManager
//extension GPS: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let dataStore else {
//            logger?.log("Failed to Read GPS Data. DataStore Initialization Failed.", logLevel: .error)
//            return
//        }
//        if let location = locations.last {
//            let currentTimestamp: Double = DateUtil().getCurrentTimestamp(to: .SECOND)
//
//            if lastSampleTimestamp == nil || currentTimestamp - lastSampleTimestamp! >= sampleFrequency {
//                var latitude = location.coordinate.latitude
//                var longitude = location.coordinate.longitude
//                var altitude = location.altitude
//                latitude += fuzzLatitudeOffset
//                longitude += fuzzLongitudeOffset
//                altitude += fuzzAltitudeOffset
//
//                let data = GPSData(
//                    timestamp: Int64(currentTimestamp * 1000),
//                    latitude: latitude,
//                    longitude: longitude,
//                    altitude: altitude,
//                    accuracy: location.horizontalAccuracy,
//                    locationTime: Int64(location.timestamp.timeIntervalSince1970 * 1000),
//                    provider: "gps",
//                    tz: DateUtil().getCurrentTimeZoneMinutesFromGMT())
//
//                dataStore.store(data)
//                UserDefaults.standard.setValue(
//                    currentTimestamp,
//                    forKey: Constants.UserDefaultKeys.gpsLastReadingEndTimeKey)
//                lastSampleTimestamp = currentTimestamp
//                noOfSamplesSoFar += 1
//            }
//        }
//    }
//}

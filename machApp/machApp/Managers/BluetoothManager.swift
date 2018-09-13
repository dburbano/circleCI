//
//  BluetoothManager.swift
//  machApp
//
//  Created by lukas burns on 7/11/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

protocol BluetoothManagerDelegate {
    func didFoundBeaconWith(major: UInt16, minor: UInt16)

    func didFoundBeacons(devicesBeacons: [DeviceBeacon])
}

class BluetoothManager: NSObject {

    #if DEBUG || AUTOMATION
        let localBeaconUUID = "2A12C3EE-3CD9-479E-91EB-DAD6BB19D71B"
    #elseif STAGING
        let localBeaconUUID = "E7167E9F-F642-426D-8FAA-26EA3F63A39C"
    #else
        let localBeaconUUID = "32CB1F26-12EC-4B73-AA26-63417C658911"
    #endif

    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(UInt16.max)
    var localBeaconMinor: CLBeaconMinorValue = 0
    var beaconRegion: CLBeaconRegion? = nil

    var locationManager: CLLocationManager!
    var delegate: BluetoothManagerDelegate?

    static let sharedInstance: BluetoothManager = {
        let instance = BluetoothManager()
        instance.beaconRegion = instance.beaconRegionWithItem()
        return instance
    }()

    func initLocalBeacon(minor: UInt16, major: UInt16) {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: "")
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }

    func stopLocalBeacon() {
        if localBeacon != nil {
            peripheralManager.stopAdvertising()
        }
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }

    func startLoactingBeacons() {
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if let beaconRegion = beaconRegion {
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(in: beaconRegion)
        }

    }

    func stopLoactingBeacons() {
        if let beaconRegion = beaconRegion {
            locationManager.stopRangingBeacons(in: beaconRegion)
            locationManager.stopMonitoring(for: beaconRegion)
        }
        locationManager = nil
    }

    func beaconRegionWithItem() -> CLBeaconRegion {
        let uuid = UUID(uuidString: localBeaconUUID)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                          identifier: "")
        return beaconRegion
    }

    func isBluetoothOn() -> Bool {
        return localBeacon != nil && locationManager != nil
    }
}

extension BluetoothManager : CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]?)
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
}

extension BluetoothManager : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        var deviceBeacons: [DeviceBeacon] = []
        for beacon in  beacons {
            debugPrint(beacon)
            debugPrint(region)
            if abs(beacon.rssi) > 0 {
                delegate?.didFoundBeaconWith(major: beacon.major.uint16Value, minor: beacon.minor.uint16Value)
                deviceBeacons.append(DeviceBeacon(major: Int(beacon.major.uint16Value), minor: Int(beacon.minor.uint16Value)))
            }
        }
        delegate?.didFoundBeacons(devicesBeacons: deviceBeacons)
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        debugPrint(error)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        debugPrint(region)
    }

}

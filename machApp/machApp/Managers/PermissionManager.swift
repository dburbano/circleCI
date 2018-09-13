//
//  PermissionManager.swift
//  machApp
//
//  Created by lukas burns on 3/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import CoreLocation
import CoreBluetooth

enum Permission {
    case pushNotifications
    case contacts
    case locationServices
}

class PermissionManager: NSObject {

    static let sharedInstance: PermissionManager = PermissionManager()
    
    var locationPermissionCallback: ((Bool) -> Void)?

    let locationManager = CLLocationManager()

    func isGranted(permission: Permission) -> Bool {
        switch permission {
        case .pushNotifications:
            return isPushNotificationsPermissionGranted()
        case .contacts:
            return isContactsPermissionGranted()
        case .locationServices:
            return isLocationServicesPermissionGranted()
        }
    }

    func askFor(permission: Permission, onComplete: @escaping(_ isGranted: Bool) -> Void) {
        switch permission {
        case .pushNotifications:
            break
        case .contacts:
            askForContactsPermission(onComplete: { (isGranted) in
                onComplete(isGranted)
            })
        case .locationServices:
            askForLocationsServicePermission(onComplete: { (isGranted) in
                onComplete(isGranted)
            })
            
        }
    }

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }

    // MARK: - Check Permissions Status

    internal func isPushNotificationsPermissionGranted() -> Bool {
        let authorizationStatus = UIApplication.shared.isRegisteredForRemoteNotifications
        return authorizationStatus
    }

    internal func isContactsPermissionGranted() -> Bool {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authorizationStatus == .authorized {
            return true
        }
        return false
    }

    internal func isLocationServicesPermissionGranted() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
        // locations services are on
            return true
        case .restricted, .denied:
        // locations services off, not determined or denied
            return false
        case .notDetermined:
            return false
        }
    }

    internal func askToActivateBluetoothIfNotActive() {
        let opt = [CBCentralManagerOptionShowPowerAlertKey: true]
        _ = CBCentralManager(delegate: self, queue: nil, options: opt)
    }

    // MARK: - Ask for Permissions
    internal func askForContactsPermission(onComplete: @escaping (_ isGranted: Bool) -> Void) {
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: CNEntityType.contacts) { (isGranted, _) in
            onComplete(isGranted)
        }
    }

    internal func askForLocationsServicePermission(onComplete: @escaping (_ isGranted: Bool) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            // locations services are on
            onComplete(true)
        case .restricted, .denied:
            onComplete(false)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension PermissionManager: CLLocationManagerDelegate, CBCentralManagerDelegate {
    /*!
     *  @method centralManagerDidUpdateState:
     *
     *  @param central  The central manager whose state has changed.
     *
     *  @discussion     Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
     *                  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code>
     *                  implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
     *                  <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
     *                  manager become invalid and must be retrieved or discovered again.
     *
     *  @see            state
     *
     */
    @available(iOS 5.0, *)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationPermissionCallback?(true)
        case .denied, .notDetermined, .restricted:
            locationPermissionCallback?(false)
        }
    }
}

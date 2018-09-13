//
//  ConfigurationManager.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import SwinjectStoryboard

class ConfigurationManager {
    static let sharedInstance = ConfigurationManager()

    private init() {}

    func save(machTeamConfiguration: MachTeamConfiguration) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.safeWrite {
                realm.add(machTeamConfiguration, update: true)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func getMachTeamConfiguration() -> MachTeamConfiguration? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            return realm.objects(MachTeamConfiguration.self).first
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }

    func didCompleteCharge() {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            guard let configuration = realm.objects(MachTeamConfiguration.self).first else { return }
            try realm.safeWrite {
                configuration.wasChargeAccepted = true
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func didShowTabBarTooltip() {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            guard let configuration = realm.objects(MachTeamConfiguration.self).first else { return }
            try realm.safeWrite {
                configuration.wasTabBarTooltipShown = true
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }
    
    func getContingencyTokenIfNotExists() {
        if ContingencyTokenManager.sharedInstance.getContingencyToken() != nil {
            return
        }
        AlamofireNetworkLayer.sharedInstance.request(ContingencyService.issueContingencyToken, onSuccess: { (networkResponse) in
            if let contingencyToken = networkResponse.body?["contingency_token"].stringValue {
                ContingencyTokenManager.sharedInstance.set(contingencyToken: contingencyToken)
            }
        }) { (networkError) in
            print("Error in obtaining Contingency Token \(networkError)")
        }
    }
    
    func switchToContingencyModeIfServersNotResponding() {
        self.isHealthCheckResponding { (areServersActive) in
            if !areServersActive {
                self.isContingencyActive(isContingencyActive: { (isContingencyStatusActive) in
                    if isContingencyStatusActive {
                        if AccountManager.sharedInstance.isLoggedIn() {
                            if ContingencyTokenManager.sharedInstance.getRefreshToken() == "" {
                                self.switchAPIToNuclearWinter()
                                self.exchangeContingencyToken(onSuccess: {
                                    self.moveToContingencyScreen()
                                }, onFailure: {
                                    //Token Exchange Failure
                                })
                            } else {
                                self.switchAPIToNuclearWinter()
                                self.moveToContingencyScreen()
                            }
                        } else {
                            self.switchAPIToNuclearWinter()
                        }
                    }
                })
            }
        }
    }
    
    private func switchAPIToNuclearWinter() {
        AlamofireNetworkLayer.sharedInstance = AlamofireNetworkLayer(contingencyMode: true)
        let container = SwinjectStoryboard.defaultContainer
        container.register(APIServiceProtocol.self) { _ in AlamofireNetworkLayer.sharedInstance }.inObjectScope(.container)
    }
    
    private func isHealthCheckResponding(isHealthCheckActive: @escaping (Bool) -> Void) {
        AlamofireNetworkLayer.sharedInstance.request(ConfigurationService.healthCheck, onSuccess: { (_) in
            isHealthCheckActive(true)
        }) { (networkError) in
            if networkError.statusCode == NSURLErrorCannotFindHost ||
                networkError.statusCode == HttpStatusCode.Http503_ServiceUnavailable.rawValue ||
                networkError.statusCode == HttpStatusCode.Http502_BadGateaway.rawValue
            {
                isHealthCheckActive(false)
            } else {
                isHealthCheckActive(true)
            }
        }
    }
    
    private func isContingencyActive(isContingencyActive: @escaping (Bool) -> Void) {
        AlamofireNetworkLayer.sharedInstance.request(ContingencyService.contingencyStatus, onSuccess: { (networkResponse) in
            if let contingencyStatus = networkResponse.body?["is_contingency_active"].boolValue {
                isContingencyActive(contingencyStatus)
            }
            isContingencyActive(false)
        }) { (networkError) in
            print(networkError)
            isContingencyActive(false)
        }
    }
    
    func moveToContingencyScreen() {
        let storyboard = UIStoryboard(name: "More", bundle: nil)
        APISecurityManager.sharedInstance.createCipherKeyIfNotPresent(shouldForceCreate: false)
        if let rootViewController = storyboard.instantiateViewController(withIdentifier: "withdrawHome") as? WithdrawViewController, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            rootViewController.isInContingency = true
            let navController = UINavigationController(rootViewController: rootViewController)
            navController.navigationBar.isHidden = true
            appDelegate.window?.rootViewController = navController
            //appDelegate.passcodeManager.presentPasscode()
        }
    }
    
    private func exchangeContingencyToken(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        AlamofireNetworkLayer.sharedInstance.request(ContingencyService.exchangeContingencyToken(contingencyToken: ContingencyTokenManager.sharedInstance.getContingencyToken() ?? ""), onSuccess: { (_) in
            onSuccess()
            print("Successfully exchanged contingency token")
        }) { (networkError) in
            print("Error exchanging contingency tokens")
            print(networkError)
            onFailure()
        }
    }
        
}

//
//  APNManager.swift
//  machApp
//
//  Created by lukas burns on 3/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class APNManager {

    static let apnTokenString: String = "APNToken"

    func performAPNTokenRegistration(tokenDevice: Data) {
        var tokenString: String = ""
        for i in 0..<tokenDevice.count {
            tokenString += String(format: "%02.2hhx", tokenDevice[i] as CVarArg)
        }
        let cleanToken = self.cleanToken(deviceToken: tokenString)
        print(cleanToken)

        APNManager.saveToken(token: tokenString)
        APNManager.registerTokenToService(token: tokenString)
    }

    private func cleanToken(deviceToken: String?) -> String {
        var result: String = ""
        guard let deviceToken = deviceToken else {
            return result
        }
        result = deviceToken.trimmingCharacters(in: CharacterSet(charactersIn:"< >"))
        result = deviceToken.replacingOccurrences(of: " ", with: "")
        return result
    }

    class func saveToken(token: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(token, forKey: APNManager.apnTokenString)
        userDefaults.synchronize()
    }

    class func loadToken() -> String? {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: APNManager.apnTokenString) as? String else {
            return nil
        }
        return data
    }

    class func registerTokenToService(token: String) {
        let deviceTokenInformation = DeviceNotificationInformation(deviceToken: token)
        do {
            try AlamofireNetworkLayer.sharedInstance.request(NotificationeService.registerDevice(parameters: deviceTokenInformation.toParams()), onSuccess: { (_) in
            }) { (_) in
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

}

//
//  PasscodeRepository.swift
//  machApp
//
//  Created by lukas burns on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class PasscodeRepository: PasscodeRepositoryProcotol {
    
    var apiService: APIServiceProtocol?
    var errorParser: PasscodeErrorParser?
    
    required init(apiService: APIServiceProtocol?, errorParser: PasscodeErrorParser?) {
        self.apiService = apiService
        self.errorParser = errorParser
    }

    public func getPasscode() -> [String]? {
        return AccountManager.sharedInstance.getPasscode()
    }
    
    public func getEncryptedPasscode() -> String? {
        return AccountManager.sharedInstance.getEncryptedPasscode()
    }

    public func hasPasscode() -> Bool {
        return AccountManager.sharedInstance.hasPasscode()
    }
    
    func hasEncryptedPasscode() -> Bool {
        return AccountManager.sharedInstance.hasEncryptedPasscode()
    }

    public func getNumberOfAttempts() -> Int {
        return AccountManager.sharedInstance.getNumberOfPinAttempts()
    }

    public func resetNumberOfAttempts() {
        AccountManager.sharedInstance.setNumberOfPinAttempts(number: 0)
    }

    public func incrementNumberOfAttemptsByOne() {
        let previousAttempts = AccountManager.sharedInstance.getNumberOfPinAttempts()
        AccountManager.sharedInstance.setNumberOfPinAttempts(number: previousAttempts + 1)
    }
    
    public func setEncryptedPasscode(passcode: [String]) {
        AccountManager.sharedInstance.setAndEncrypt(passcode: passcode)
    }
    
    public func getUseTouchId() -> Bool {
        return AccountManager.sharedInstance.getUseTouchId()
    }
}

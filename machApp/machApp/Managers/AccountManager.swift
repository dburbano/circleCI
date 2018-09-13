//
//  AccountManager.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift
import RealmSwift

class AccountManager: NSObject {
    static let sharedInstance: AccountManager = AccountManager()
    static let passcodeKey: String = "PASS_CODE"
    static let encryptedPasscodeKey: String = "ENCRYPTED_PASS_CODE"
    static let machIdKey: String = "MACH_ID"
    static let rutNameKey: String = "RUT"
    static let cashinAccountKey: String = "CASHIN_ACCOUNT"
    static let cashinAccountType: String = "CASHIN_ACCOUNT_TYPE"
    static let cashinBankKey: String = "CASHIN_BANK"
    static let cashoutAccountKey: String = "CASHOUT_ACCOUNT"
    static let cashoutBankName: String = "CASHOUT_BANK_NAME"
    static let cashoutAccountType: String = "CASHOUT_ACCOUNT_TYPE"
    static let cashoutBankKey: String = "CASHOUT_BANK"
    static let numberOfPinAttemtps: String = "NUMBER_OF_PIN_ATTEMPTS"
    static let requestReminderInformationKey: String = "REMINDER_INFORMATION" //
    static let useTouchIdKey: String = "USE_TOUCH_ID"
    static let dateKey: String = "DATE"
    static let hideRequestNDialogue: String = "HIDE_REQUEST_N_DIALOGUE"
    static let hideWithdrawATMcreatedMessage: String = "HIDE_WITHDRAW_ATM_CREATED_MESSAGE"
    static let lastSyncPhoneContacts: String = "LAST_SYNC_PHONE_CONTACTS"
    static let accountCreationInProcessKey: String = "ACCOUNT_CREATION_IN_PROCESS"
    static let userFirstName: String = "USER_FIRST_NAME"
    static let userLastName: String = "USER_LAST_NAME"
    static let userHasAccessedPrepaidCard: String = "USER_HAS_ACCESSED_PREPAID_CARD"

    let userDefaults = UserDefaults.standard

    var logged: Bool = false
    let defaults: UserDefaults = UserDefaults.standard
    let keychain = KeychainSwift()

    override init() {
        super.init()
    }

    func isLoggedIn() -> Bool {
        return AccountManager.sharedInstance.defaults.bool(forKey: "registered")
    }

    func performLogin() {
        logged = true
        defaults.set(logged, forKey: "registered")
        RealmManager.createSeedReactions()
    }

    func performLogOut(deleteTokens: Bool = true) {
        logged = false
        NotificationManager.sharedInstance.stop()
        NotificationCenter.default.post(name: .UserDataDeleted, object: nil)

        if deleteTokens {
            AuthTokenManager.sharedInstance.deleteAccessToken()
            AuthTokenManager.sharedInstance.deleteRefreshToken()
            ContingencyTokenManager.sharedInstance.deleteAccessToken()
            ContingencyTokenManager.sharedInstance.deleteRefreshToken()
            ContingencyTokenManager.sharedInstance.deleteContingencyToken()
        }
        AccountManager.sharedInstance.deletePasscode()
        AccountManager.sharedInstance.deleteEncryptedPasscode()
        AccountManager.sharedInstance.deleteMachId()
        AccountManager.sharedInstance.deleteRut()
        AccountManager.sharedInstance.deleteCashoutAccount()
        AccountManager.sharedInstance.deleteCashoutBank()
        AccountManager.sharedInstance.deleteCashoutBankName()
        AccountManager.sharedInstance.deleteCashinAccount()
        AccountManager.sharedInstance.deleteCashinBank()
        AccountManager.sharedInstance.deleteCashinAccountType()
        AccountManager.sharedInstance.deleteDate()
        APISecurityManager.sharedInstance.deleteCipherKey()
        APISecurityManager.sharedInstance.deletePublicKey()
        APISecurityManager.sharedInstance.deletePrivateKey()
        UserPhotoManager.sharedInstance.deleteUserProfileImage()
        CreditCardManager.sharedInstance.deleteCurrentCreditCard()
        AccountManager.sharedInstance.deleteIsAccountCreationInProcess()
        AccountManager.sharedInstance.deleteUserFirstName()
        AccountManager.sharedInstance.deleteUserLastName()
        defaults.set(logged, forKey: "registered")
        defaults.set(false, forKey: AccountManager.requestReminderInformationKey)
        deleteRealm()
    }
    
    func deleteRealm() {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func getPasscode() -> [String]? {
        if let stringCode = keychain.get(AccountManager.passcodeKey) {
            return formatPasscodeTo(array: stringCode)
        }
        return nil
    }

    private func formatPasscodeTo(array code: String) -> [String] {
        var passcode: [String] = []
        for code in code {
            passcode.append(code.toString)
        }
        return passcode
    }

    func hasPasscode() -> Bool {
        return keychain.get(AccountManager.passcodeKey) != nil
    }

    func deletePasscode() {
        keychain.delete(AccountManager.passcodeKey)
    }
    
    func setAndEncrypt(passcode: [String]) {
        if let encryptedPasscode = passcode.compactMap({$0}).joined().sha256() {
            keychain.set(encryptedPasscode, forKey: AccountManager.encryptedPasscodeKey)
        }
    }
    
    func getEncryptedPasscode() -> String? {
        return keychain.get(AccountManager.encryptedPasscodeKey)
    }
    
    func hasEncryptedPasscode() -> Bool {
        return keychain.get(AccountManager.encryptedPasscodeKey) != nil
    }
    
    func deleteEncryptedPasscode() {
        keychain.delete(AccountManager.encryptedPasscodeKey)
    }

    func set(machId: String) {
        keychain.set(machId, forKey: AccountManager.machIdKey)
    }

    func getMachId() -> String? {
        return keychain.get(AccountManager.machIdKey)
    }

    func deleteMachId() {
        keychain.delete(AccountManager.machIdKey)
    }

    func set(rut: String) {
        userDefaults.set(rut, forKey: AccountManager.rutNameKey)
    }

    func getRut() -> String? {
        return userDefaults.object(forKey: AccountManager.rutNameKey) as? String
    }

    func set(cashinAccountNumber: String) {
        userDefaults.set(cashinAccountNumber, forKey: AccountManager.cashinAccountKey)
    }

    func set(cashoutBankName: String) {
        userDefaults.set(cashoutBankName, forKey: AccountManager.cashoutBankName)
    }
    
    func set(cashoutAccountNumber: String) {
        userDefaults.set(cashoutAccountNumber, forKey: AccountManager.cashoutAccountKey)
    }

    func set(cashinAccountType: String) {
        userDefaults.set(cashinAccountType, forKey: AccountManager.cashinAccountType)
    }

    func set(cashinBank: String) {
        userDefaults.set(cashinBank, forKey: AccountManager.cashinBankKey)
    }

    func set(cashoutBank: String) {
        userDefaults.set(cashoutBank, forKey: AccountManager.cashoutBankKey)
    }

    func set(date: Date) {
        userDefaults.set(date, forKey: AccountManager.dateKey)
    }

    func set(dateToLastSyncPhoneContacts: Date) {
        userDefaults.set(dateToLastSyncPhoneContacts, forKey: AccountManager.lastSyncPhoneContacts)
    }

    func deleteDate() {
        userDefaults.removeObject(forKey: AccountManager.dateKey)
    }

    func deleteRut() {
        userDefaults.removeObject(forKey: AccountManager.rutNameKey)
    }

    func deleteCashinAccount() {
        userDefaults.removeObject(forKey: AccountManager.cashinAccountKey)
    }

    func deleteCashoutAccount() {
        userDefaults.removeObject(forKey: AccountManager.cashoutAccountKey)
    }
    
    func deleteCashoutBankName() {
        userDefaults.removeObject(forKey: AccountManager.cashoutBankName)
    }

    func deleteCashinBank() {
        userDefaults.removeObject(forKey: AccountManager.cashinBankKey)
    }

    func deleteCashoutBank() {
        userDefaults.removeObject(forKey: AccountManager.cashoutBankKey)
    }

    func deleteCashinAccountType() {
        userDefaults.removeObject(forKey: AccountManager.cashinAccountType)
    }

    func getLastSyncPhoneContacts() -> Date? {
        guard let date = userDefaults.object(forKey: AccountManager.lastSyncPhoneContacts) as? Date else { return nil }
        return date
    }

    func getDate() -> Date? {
        guard let date = userDefaults.object(forKey: AccountManager.dateKey) as? Date else { return nil }
        return date
    }

    func getCashinBank() -> String? {
        return userDefaults.string(forKey: AccountManager.cashinBankKey)
    }

    func getCashoutBank() -> String? {
        return userDefaults.string(forKey: AccountManager.cashoutBankKey)
    }

    func getCashinAccountNumber() -> String? {
        return userDefaults.string(forKey: AccountManager.cashinAccountKey)
    }

    func getCashoutAccountNumber() -> String? {
        return userDefaults.string(forKey: AccountManager.cashoutAccountKey)
    }
    
    func getCashoutBankName() -> String? {
        return userDefaults.string(forKey: AccountManager.cashoutBankName)
    }

    func getCashinAccountType() -> String? {
        return userDefaults.string(forKey: AccountManager.cashinAccountType)
    }

    func getCashoutAccountType() -> String? {
        return userDefaults.string(forKey: AccountManager.cashoutAccountType)
    }

    func getIsMailValidated() -> Bool {
        guard let user = AccountManager.sharedInstance.getUser() else { return false}
        return user.emailConfirmedAt == nil ? false : true
    }

    func saveUser(user: User) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                realm.add(user, update: true)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func updateFirstName(firstName: String?) {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                user.firstName = firstName
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func updateLastName(lastName: String?) {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                user.lastName = lastName
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func updateEmail(email: String?) {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                user.email = email
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func updateEmailValidated(with date: NSDate?) {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                user.emailConfirmedAt = date
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func updateProfileImage(images: Images?) {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                user.images = images
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func updateBluetoothDevice(deviceBeacon: DeviceBeacon?) {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                user.deviceBeacon = deviceBeacon
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func updatePhoneNumber(phoneNumber: String?) {
        guard let user = AccountManager.sharedInstance.getUser() else { return }
        guard let phone = phoneNumber else { return }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                user.phone = phone
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func getUser() -> User? {
        var user: User?
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.write {
                guard let machId = AccountManager.sharedInstance.getMachId() else { return }
                user = realm.objects(User.self).filter("machId = %@", machId).first
            }
        } catch {
            return user
        }
        return user
    }
    
    func set(userLastName: String) {
        userDefaults.set(userLastName, forKey: AccountManager.userLastName)
    }
    
    func getUserLastName() -> String {
        return userDefaults.string(forKey: AccountManager.userLastName) ?? ""
    }
    
    func deleteUserLastName() {
        userDefaults.removeObject(forKey: AccountManager.userLastName)
    }
    
    func set(userFirstName: String) {
        userDefaults.set(userFirstName, forKey: AccountManager.userFirstName)
    }
    
    func getUserFirstName() -> String {
        return userDefaults.string(forKey: AccountManager.userFirstName) ?? ""
    }
    
    func deleteUserFirstName() {
        userDefaults.removeObject(forKey: AccountManager.userFirstName)
    }

    func setNumberOfPinAttempts(number: Int) {
        userDefaults.set(number, forKey: AccountManager.numberOfPinAttemtps)
    }

    func getNumberOfPinAttempts() -> Int {
        return userDefaults.integer(forKey: AccountManager.numberOfPinAttemtps)
    }

    func set(useTouchId: Bool) {
        userDefaults.set(useTouchId, forKey: AccountManager.useTouchIdKey)
    }

    func getUseTouchId() -> Bool {
        return userDefaults.bool(forKey: AccountManager.useTouchIdKey)
    }

    func set(hideWithdrawATMcreatedMessage: Bool) {
        userDefaults.set(hideWithdrawATMcreatedMessage, forKey: AccountManager.hideWithdrawATMcreatedMessage)
    }

    func getHideWithdrawATMCreatedMessage() -> Bool {
        return userDefaults.bool(forKey: AccountManager.hideWithdrawATMcreatedMessage)
    }

    func set(hideRequestNDialogue: Bool) {
        userDefaults.set(hideRequestNDialogue, forKey: AccountManager.hideRequestNDialogue)
    }

    func getHideRequestNDialogue() -> Bool {
        return userDefaults.bool(forKey: AccountManager.hideRequestNDialogue)
    }

    func fetchAndUpdateUser() {
        AlamofireNetworkLayer.sharedInstance.request(ProfileService.me, onSuccess: { (networkResponse) in
            do {
                let userProfileResponse = try UserProfileResponse.create(from: networkResponse.body!)
                self.updateUserWithProfileResponse(userProfileResponse: userProfileResponse)
                SegmentManager.sharedInstance.identifyUser()
                NotificationCenter.default.post(name: .ProfileDidUpdate, object: nil)
            } catch {
                ExceptionManager.sharedInstance.recordError(error)
            }
        }) { (networkError) in
            networkError.printDescription()
        }
    }

    func hasRequestReminderInformationBeenShown() -> Bool {
        return defaults.bool(forKey: AccountManager.requestReminderInformationKey)
    }

    func setHasRequestReminderInformationBeenShown(with value: Bool) {
        defaults.set(value, forKey: AccountManager.requestReminderInformationKey)
    }
    
    func isAccountCreationInProcess() -> Bool {
        return defaults.bool(forKey: AccountManager.accountCreationInProcessKey)
    }
    
    func setIsAccountCreationInProcess(with value: Bool) {
        defaults.set(value, forKey: AccountManager.accountCreationInProcessKey)
    }
    
    func deleteIsAccountCreationInProcess() {
        defaults.removeObject(forKey: AccountManager.accountCreationInProcessKey)
    }

    func updateUserWithProfileResponse(userProfileResponse: UserProfileResponse) {
        self.updateEmailValidated(with: userProfileResponse.emailConfirmedAt)
        self.updateEmail(email: userProfileResponse.email)
        self.updateFirstName(firstName: userProfileResponse.firstName)
        self.updateLastName(lastName: userProfileResponse.lastName)
        self.updateProfileImage(images: userProfileResponse.images)
        self.updateBluetoothDevice(deviceBeacon: userProfileResponse.deviceBeacon)
        self.updatePhoneNumber(phoneNumber: userProfileResponse.phone)
        print("User profile updated succesfully")
    }
    
    func setUserHasAccessedPrepaidCard(accessed: Bool) {
        defaults.set(accessed, forKey: AccountManager.userHasAccessedPrepaidCard)
    }
    
    func userHasAccessedPrepaidCard() -> Bool {
        return defaults.bool(forKey: AccountManager.userHasAccessedPrepaidCard)
    }

}

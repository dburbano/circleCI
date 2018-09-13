//
//  ContactManager.swift
//  machApp
//
//  Created by lukas burns on 7/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import RealmSwift
import Contacts

class ContactManager {

    static let sharedInstance = ContactManager()

    // Refactor this method
    func upsertUser(receivedUser: User) -> User? {

//        guard let receivedUserMachId = receivedUser.machId, let currentUserMachId = AccountManager.sharedInstance.getUser()?.machId, receivedUserMachId != currentUserMachId else {
//            return AccountManager.sharedInstance.getUser()
//        }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            guard let machId = receivedUser.machId else { return nil }
            if let user = getUserBy(machId: machId) {
                // Found user by mach ID
                if user.phone?.cleanPhoneNumber() == receivedUser.phone?.cleanPhoneNumber() || (user.phone?.cleanPhoneNumber() != nil && receivedUser.phone?.cleanPhoneNumber() == nil ) {
                    // Mach ID hasn't changed phone nubmers
                    updateUsersRemoteData(localUser: user, receivedUser: receivedUser)
                } else {
                    // Mach ID has changed phone number
                    self.updateUsersRemoteData(localUser: user, receivedUser: receivedUser)
                    if let newFoundUser = self.getUserBy(phoneNumber: receivedUser.phone) {
                        // We create a temp user to save the first user found by mach id
                        let tempUser = User()
                        tempUser.firstNamePhone = user.firstNamePhone
                        tempUser.lastNamePhone = user.lastNamePhone
                        tempUser.phone = user.phone
                        tempUser.imagePhone = user.imagePhone
                        // we now update the users local data with the second user found with the mach id
                        self.updateUsersLocalData(localUser: user, receivedContact: newFoundUser)
                        // we now set the second user with the temp data
                        try realm.safeWrite {
                            user.phone = receivedUser.phone
                            newFoundUser.firstNamePhone = tempUser.firstNamePhone
                            newFoundUser.lastNamePhone = tempUser.lastNamePhone
                            newFoundUser.phone = tempUser.phone
                            newFoundUser.imagePhone = tempUser.imagePhone
                            newFoundUser.machId = nil
                            realm.add(newFoundUser, update: true)
                        }

                    } else {
                        // No user was found
                        try realm.safeWrite {
                            user.machId = receivedUser.machId
                            user.isInContacts = false
                            user.imagePhone = nil
                            user.lastNamePhone = nil
                            user.firstNamePhone = nil
                            user.phone = receivedUser.phone
                            realm.add(user, update: true)
                        }
                    }
                }
                return user
            } else if let user = getUserBy(phoneNumber: receivedUser.phone) {
                // Found user by phone
                updateUsersRemoteData(localUser: user, receivedUser: receivedUser)
                return user
            } else {
                // Didnt find user
                try realm.safeWrite {
                    realm.add(receivedUser, update: true)
                }
                return receivedUser
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }

    func getUserBy(machId: String) -> User? {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            return realm.objects(User.self).filter("machId = %@", machId).first
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }

    func getUserBy(phoneNumber: String?) -> User? {
        guard let phoneNumber = phoneNumber else { return nil }
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let cleanedPhoneNumber = phoneNumber.cleanPhoneNumber()
            return realm.objects(User.self).filter("phone = %@", cleanedPhoneNumber).first
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            return nil
        }
    }

    func updateUsersRemoteData(localUser: User, receivedUser: User) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.safeWrite {
                localUser.machId = receivedUser.machId
                localUser.imagePhone = receivedUser.imagePhone
                localUser.firstName = receivedUser.firstName
                localUser.lastName = receivedUser.lastName
                localUser.email = receivedUser.email
                localUser.deviceBeacon = receivedUser.deviceBeacon
                localUser.emailConfirmedAt = receivedUser.emailConfirmedAt
                localUser.images = receivedUser.images
                realm.add(localUser, update: true)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func updateUsersLocalData(localUser: User, receivedContact: User) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            try realm.safeWrite {
                localUser.firstNamePhone = receivedContact.firstNamePhone
                localUser.lastNamePhone = receivedContact.lastNamePhone
                localUser.imagePhone = receivedContact.imagePhone
                localUser.isFirstNameFirst = receivedContact.isFirstNameFirst
                localUser.isInContacts = receivedContact.isInContacts
                realm.add(localUser, update: true)
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    func retrieveContacts(completion: (_ success: Bool, _ contacts: [User]?) -> Void) {
        var contacts = [User]()
        do {
            let keysToFetch: [Any] = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactImageDataAvailableKey, CNContactPhoneNumbersKey]
            let contactStore = CNContactStore()
            // swiftlint:disable:next force_cast
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            contactsFetchRequest.sortOrder = CNContactsUserDefaults.shared().sortOrder
            var isFirstNameFirst: Bool? = true
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, _) in
                if isFirstNameFirst == nil {
                    if !cnContact.givenName.isEmpty || !cnContact.familyName.isEmpty {
                        isFirstNameFirst = CNContactFormatter.nameOrder(for: cnContact) == CNContactDisplayNameOrder.givenNameFirst
                    }
                }
                let user = User(cnContact: cnContact)
                if let isFirstNameFirst = isFirstNameFirst {
                    user.isFirstNameFirst = isFirstNameFirst
                }
                if let phone = user.phone, phone.isValidPhoneNumber {
                    user.isInContacts = true
                    contacts.append(user)
                }
            })
            completion(true, contacts)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            completion(false, nil)
        }
    }

    func syncContacts() {
        let startTime = CFAbsoluteTimeGetCurrent()
        DispatchQueue(label: "background").async {
            autoreleasepool {
                self.retrieveContacts(completion: { (success, users) in
                    if success, let users = users {
                        self.saveUsers(users: users)
                        self.refreshDeletedUsers(contacts: users)
                        self.sendUsers(users: users)
                    }
                })
            }
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print(timeElapsed)
    }

    func saveUsers(users: [User]) {
        let startTime = CFAbsoluteTimeGetCurrent()
        for user in users {
            self.upsertContact(contact: user)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Save User: \(users.count) in \(timeElapsed)")
    }

    func upsertContact(contact: User) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            if let phone = contact.phone?.cleanPhoneNumber(), let user = realm.objects(User.self).filter("phone = %@", phone).first {
                self.updateUsersLocalData(localUser: user, receivedContact: contact)
            } else {
                try realm.safeWrite {
                    realm.add(contact, update: true)
                }
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            print(error)
        }
    }

    func setUsersAsProcessed(users: [User]) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            for user in users {
                try realm.safeWrite {
                    user.wasProcessed = true
                    realm.add(users, update: true)
                }
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            print(error)
        }
    }

    func refreshDeletedUsers(contacts: [User]) {
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let localUsers = realm.objects(User.self)
            for localUser in localUsers {
                if contacts.index(where: { (contact) -> Bool in
                    return contact.phone?.cleanPhoneNumber() == localUser.phone?.cleanPhoneNumber()
                }) == nil {
                    try realm.safeWrite {
                        localUser.isInContacts = false
                        realm.add(localUser, update: true)
                    }
                }
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            print(error)
        }
    }

    private func uploadPhoneNumbers(phoneNumbers: [String], onSuccess: @escaping () -> Void, onFailure: @escaping (ApiError) -> Void) {
        do {
            AlamofireNetworkLayer.sharedInstance.request(ContactService.upload(parameters: ["contacts": phoneNumbers]), onSuccess: { (networkResponse) in
                onSuccess()
            }, onError: { (responseError) in
                onFailure((ErrorParser().getError(networkError: responseError)))
            })
        }
    }

    private func sendUsers(users: [User]) {
        var phoneNumbers: [String] = []
        let maxNumberOfContacts = 500
        do {
            let realm = try Realm(configuration: RealmManager.getRealmConfiguration())
            let users = realm.objects(User.self)
        for user in users {
            if let phone = user.phone?.cleanPhoneNumber(), user.machId == nil {
//                print("Appending user")
                phoneNumbers.append(phone)
            }
            if phoneNumbers.count == maxNumberOfContacts {
                self.uploadPhoneNumbers(phoneNumbers: phoneNumbers, onSuccess: {
                    // Users uploaded
                    //self.setUsersAsProcessed(users: users)
                }, onFailure: { (apiError) in
                    // Error uploading
                })
                phoneNumbers = []
            }
        }
        self.uploadPhoneNumbers(phoneNumbers: phoneNumbers, onSuccess: {
            // Users uploaded
            //self.setUsersAsProcessed(users: users)
        }, onFailure: { (apiError) in
            // Error uploading
        })
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    // MARK: send contacts info
    /* New way to send contacts */

    private func retrieveContactsFromCNContact(completion: (_ success: Bool, _ contacts: [ContactPhoneInformation]?) -> Void) {
        var contacts = [ContactPhoneInformation]()
        do {
            let keysToFetch: [Any] = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
            let contactStore = CNContactStore()
            // swiftlint:disable:next force_cast
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            contactsFetchRequest.sortOrder = CNContactsUserDefaults.shared().sortOrder
            var isFirstNameFirst: Bool? = true
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, _) in
                if isFirstNameFirst == nil {
                    if !cnContact.givenName.isEmpty || !cnContact.familyName.isEmpty {
                        isFirstNameFirst = CNContactFormatter.nameOrder(for: cnContact) == CNContactDisplayNameOrder.givenNameFirst
                    }
                }
                let user = ContactPhoneInformation(cnContact: cnContact)
                contacts.append(user)
            })
            completion(true, contacts)
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
            completion(false, nil)
        }
    }

    private func syncPhoneContacts() {
        DispatchQueue(label: "background").async {
            autoreleasepool {
                self.retrieveContactsFromCNContact(completion: { (success, users) in
                    if success, let users = users {
                        self.sendContacts(users: users)
                        AccountManager.sharedInstance.set(dateToLastSyncPhoneContacts: Date())
                    }
                })
            }
        }
    }

    private func sendContacts(users: [ContactPhoneInformation]) {
        var contacts: [ContactPhoneInformation] = []
        let maxNumberOfContacts = 500

        for user in users {
            contacts.append(user)
            if contacts.count == maxNumberOfContacts {
                self.uploadContacts(contacts: contacts)
                contacts = []
            }
        }
        self.uploadContacts(contacts: contacts)
    }

    private func uploadContacts(contacts: [ContactPhoneInformation]) {
        do {
            let contactsPhone = ContactsPhoneInformation(contacts: contacts)
            try AlamofireNetworkLayer.sharedInstance.request(
                ContactService.uploadContacts(parameters: contactsPhone.toParams()),
                onSuccess: { (networkResponse) in
                    // Do nothing
                }, onError: { (responseError) in
                    // Do nothing
                })
        } catch {
            // Do nothing
        }
    }

    public func sendPhoneContacts() {
        let dateLastSync = AccountManager.sharedInstance.getLastSyncPhoneContacts() ?? Date().addMonths(number: -1)
        let diff = Calendar.current.dateComponents([.day], from: dateLastSync, to: Date())

        if Reachability.isConnectedToNetwork() && diff.day ?? 8 > 7 {
            self.syncPhoneContacts()
        }
    }

}

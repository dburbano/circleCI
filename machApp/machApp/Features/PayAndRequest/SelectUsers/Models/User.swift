//
//  User.swift
//  machApp
//
//  Created by lukas burns on 3/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Wrap
import Contacts
import RealmSwift
import Unbox
import SwiftyJSON

class User: Object, Unboxable {

    @objc dynamic var identifier: String?
    @objc dynamic var contactIdentifier: String?
    @objc dynamic var machId: String?
    @objc dynamic var firstName: String?
    @objc dynamic var firstNamePhone: String?
    @objc dynamic var lastNamePhone: String?
    @objc dynamic var lastName: String?
    @objc dynamic var imagePhone: NSData?
    @objc dynamic var phone: String?
    @objc dynamic var images: Images?
    @objc dynamic var email: String?
    @objc dynamic var isInContacts: Bool = false
    @objc dynamic var wasProcessed: Bool = false
    @objc dynamic var isFirstNameFirst: Bool = true
    @objc dynamic var deviceBeacon: DeviceBeacon?
    @objc dynamic var emailConfirmedAt: NSDate?

    convenience init(firstName: String?, lastName: String?, imageData: NSData?, phone: String?, images: Images?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.imagePhone = imageData
        self.phone = phone?.cleanPhoneNumber()
        self.images = images
        self.setPrimaryKey()
    }

    convenience init(firstName: String, identifier: String, smallImage: String) {
        self.init()
        self.firstName = firstName
        self.machId = identifier
        self.images = Images(smallImage: smallImage)
    }

    convenience init(with configurationResponse: ConfigurationResponse) {
        self.init()
        self.firstName = configurationResponse.machProfile.name
        self.machId = configurationResponse.machProfile.machID
        self.images = Images(smallImage: configurationResponse.machProfile.imageUrls.small)
    }

    convenience required init(unboxer: Unboxer) throws {
        self.init()
        self.machId = unboxer.unbox(key: "machId")
        self.firstName = unboxer.unbox(key: "firstName")
        self.lastName = unboxer.unbox(key: "lastName")
        self.email = unboxer.unbox(key: "email")
        self.images = unboxer.unbox(key: "imageUrls")
        self.phone = unboxer.unbox(key: "phoneNumber")
        self.deviceBeacon = unboxer.unbox(key: "bluetoothId")
        self.phone = self.phone?.cleanPhoneNumber()
        do {
            if unboxer.dictionary["email_confirmed_at"] != nil {
                emailConfirmedAt = try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "email_confirmed_at")) as NSDate?
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
        self.setPrimaryKey()
    }

    public static func create(from dictionary: JSON) throws -> User {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: User = try unbox(dictionary: dictionaryObject)
        return response
    }

    public static func createArray(from dictionaryArray: JSON) throws -> [User] {
        guard let arrayObject = dictionaryArray.arrayObject as? [UnboxableDictionary], let response: [User] = try? unbox(dictionaries: arrayObject) else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        return response
    }

    override static func primaryKey() -> String? {
        return "identifier"
    }

    internal func setPrimaryKey() {
        if self.identifier == nil {
            self.identifier = UUID().uuidString
        }
    }
}

extension User {

    convenience init(cnContact: CNContact) {
        self.init()
        // name
        guard cnContact.isKeyAvailable(CNContactGivenNameKey) else { return }
        self.firstNamePhone = cnContact.givenName.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)

        // lastname
        guard cnContact.isKeyAvailable(CNContactFamilyNameKey) else { return }
        self.lastNamePhone = cnContact.familyName.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)

        // image
        self.imagePhone = (cnContact.isKeyAvailable(CNContactImageDataKey) && cnContact.imageDataAvailable) ? cnContact.imageData as NSData? : nil

//        // identifier
        self.contactIdentifier = cnContact.identifier

        // phone
        if cnContact.isKeyAvailable(CNContactPhoneNumbersKey) {
            for phoneNumber in cnContact.phoneNumbers {
                let phone = phoneNumber.value.stringValue
                if phone.isValidPhoneNumber {
                    self.phone = phone.cleanPhoneNumber()
                    break
                }
            }
        }
        self.isInContacts = true
        self.setPrimaryKey()
    }
}

extension User {
    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}

extension User {
    convenience init(userProfileResponse: UserProfileResponse) {
        self.init()
        self.email = userProfileResponse.email
        self.firstName = userProfileResponse.firstName
        self.lastName = userProfileResponse.lastName
        self.machId = userProfileResponse.machId
        self.images = userProfileResponse.images
        self.phone = userProfileResponse.phone?.cleanPhoneNumber()
        self.deviceBeacon = userProfileResponse.deviceBeacon
        self.emailConfirmedAt = userProfileResponse.emailConfirmedAt
        self.setPrimaryKey()
    }
}

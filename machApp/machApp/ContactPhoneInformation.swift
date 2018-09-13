//
//  ContactPhoneInformation.swift
//  machApp
//
//  Created by Rodrigo Russell on 7/5/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Wrap
import Contacts

public struct ContactPhoneInformation {
    var lastName: String
    var firstName: String
    var fullName: String
    var phones: [String]
    var emails: [String]

    public init (lastName: String, firstName: String, phones: [String], emails: [String]) {
        self.lastName = lastName
        self.firstName = firstName
        self.fullName = "\(firstName) \(lastName)"
        self.phones = phones
        self.emails = emails
    }

    public init(cnContact: CNContact) {
        if cnContact.isKeyAvailable(CNContactGivenNameKey) {
            self.firstName = cnContact.givenName.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        } else {
            self.firstName = ""
        }

        if cnContact.isKeyAvailable(CNContactFamilyNameKey) {
            self.lastName = cnContact.familyName.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        } else {
            self.lastName = ""
        }

        self.fullName = "\(self.firstName) \(self.lastName)"

        self.phones = []
        if cnContact.isKeyAvailable(CNContactPhoneNumbersKey) {
            for phoneNumber in cnContact.phoneNumbers {
                self.phones.append(phoneNumber.value.stringValue)
            }
        }

        self.emails = []
        if cnContact.isKeyAvailable(CNContactEmailAddressesKey) {
            for email in cnContact.emailAddresses {
                self.emails.append(email.value as String)
            }
        }
    }
}

extension ContactPhoneInformation: WrapCustomizable {

    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "lastName" {
            return "lastName"
        }
        if propertyName == "firstName" {
            return "firstName"
        }
        if propertyName == "fullName" {
            return "fullName"
        }
        if propertyName == "phones" {
            return "phones"
        }
        if propertyName == "emails" {
            return "emails"
        }
        
        return propertyName
    }

    public func toParams() throws -> [String: Any] {
        return try Wrapper.init().wrap(object: self)
    }
}

public struct ContactsPhoneInformation {
    var contacts: [ContactPhoneInformation] = []

    public init(contacts: [ContactPhoneInformation]) {
        self.contacts = contacts
    }
}

extension ContactsPhoneInformation: WrapCustomizable {
    public func keyForWrapping(propertyNamed propertyName: String) -> String? {
        if propertyName == "contacts" {
            return "phoneContacts"
        }
        return propertyName
    }

    public func toParams() throws -> [String : Any] {
        return try Wrapper.init().wrap(object: self)
    }
}

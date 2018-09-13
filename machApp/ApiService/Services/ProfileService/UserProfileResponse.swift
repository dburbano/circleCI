//
//  UserResponse.swift
//  machApp
//
//  Created by lukas burns on 4/12/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct UserProfileResponse {
    var firstName: String
    var lastName: String
    var birthDate: String?
    var email: String?
    var images: Images?
    var machId: String?
    var phone: String?
    var deviceBeacon: DeviceBeacon?
    var emailConfirmedAt: NSDate?
}

extension UserProfileResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.firstName = try unboxer.unbox(key: "firstName")
        self.lastName = try unboxer.unbox(key: "lastName")
        self.birthDate =  unboxer.unbox(key: "birthDate")
        self.email = unboxer.unbox(key: "email")
        self.images = unboxer.unbox(key: "imageUrls")
        self.machId = unboxer.unbox(key: "machId")
        self.phone = unboxer.unbox(key: "phoneNumber")
        self.deviceBeacon = unboxer.unbox(key: "bluetoothId")
        do {
            if unboxer.dictionary["email_confirmed_at"] != nil {
                emailConfirmedAt = try Date().dateFromISOString(isoDateString: unboxer.unbox(key: "email_confirmed_at")) as NSDate?
            }
        } catch {
            ExceptionManager.sharedInstance.recordError(error)
        }
    }

    public static func create(from dictionary: JSON) throws -> UserProfileResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: UserProfileResponse = try unbox(dictionary: dictionaryObject)
        return response
    }

}

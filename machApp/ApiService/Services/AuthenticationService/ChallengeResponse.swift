//
//  RecoverChallengeResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

struct ChallengeNameParser: UnboxFormatter {
    
    var payload: JSON
    
    init(_ payload: JSON) {
        self.payload = payload
    }
    
    func format(unboxedValue: String) -> Challenge? {
        switch unboxedValue {
        case "verify-id-document":
            let rut = self.payload["rut"].string ?? ""
            return Challenge.documentIdVerification(rut)
        case "request-security-questions":
            return Challenge.requestSecurityQuestions()
        case "check-security-answers":
            do {
                let securityQuestionsResponse = try SecurityQuestionsVerificationResponse.create(from: self.payload)
                return Challenge.checkSecurityQuestions(securityQuestionsResponse)
            } catch {
                return nil
            }
        case "request-phone-verification":
            return Challenge.requestPhoneVerification()
        case "check-phone-verification":
            do {
                let response = try PhoneNumberRegistrationChallengeResponse.create(from: payload)
                return Challenge.validatePhoneNumber(response)
            } catch { return nil }
        case "request-email-verification":
            return Challenge.requestEmail()
        case "check-email-verification":
            do {
                let response = try EmailChallengeResponse.create(from: payload)
                return Challenge.checkEmail(response)
            } catch { return nil }
        case "request-tef-verification":
            do {
                let banks = try Bank.createArray(from: payload["banks"])
                return Challenge.requestTef(banks)
            } catch { return nil }
        case "check-tef-verification":
            do {
                let tefVerificationResponse = try TEFVerificationResponse.create(from: payload)
                return Challenge.checkTef(tefVerificationResponse)
            } catch { return nil }
        default:
            return nil
        }
    }
}

public struct ChallengeResponse {
    var challenge: Challenge?
    var userInformation: UserInformationChallengeResponse?
}

extension ChallengeResponse : Unboxable {
    
    public init(unboxer: Unboxer) throws {
        let payload: JSON = JSON.init(unboxer.dictionary["payload"] as Any)
        self.challenge = unboxer.unbox(key: "name", formatter: ChallengeNameParser(payload))
        self.userInformation = unboxer.unbox(keyPath: "payload")
    }
    
    public static func create(from dictionary: JSON) throws -> ChallengeResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: ChallengeResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
    
}

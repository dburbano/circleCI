//
//  String+PhoneNumber.swift
//  machApp
//
//  Created by lukas burns on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

extension String {
    var isValidPhoneNumber: Bool {
        let phoneNumber = self.cleanPhoneNumber()

        guard !phoneNumber.isBlank else {
            return false
        }

        guard phoneNumber.isNumber() else {
            return false
        }

        guard phoneNumber.count == 11 else {
            return false
        }

        let first3Digits = phoneNumber[0 ..< 3]

        guard first3Digits == "569" else {
            return false
        }

        return true
    }

    func removeWhitespaces() -> String {
        return self.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: "")
    }

    func removeLeadingAndTrailingWhitespaces() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }

    func removeInnerSpaces() -> String {
        return self.replacingOccurrences(of: "(\\s+)", with: " ", options: .regularExpression, range: nil)

    }

    func cleanPhoneNumber() -> String {
        return self.removeWhitespaces().replacingOccurrences(of: "+", with: "")
    }

    func formatAsPhoneNumber() -> String {
        guard self.count == 11 else { return self }
        var phone = self.cleanPhoneNumber()
        phone.insert(" ", at: phone.index(phone.startIndex, offsetBy: 7))
        phone.insert(" ", at: phone.index(phone.startIndex, offsetBy: 3))
        phone.insert(" ", at: phone.index(phone.startIndex, offsetBy: 2))
        phone.insert("+", at: phone.startIndex)
        return phone
    }
}

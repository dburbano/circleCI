//
//  CreditCardManager.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/9/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class CreditCardManager {

    static let sharedInstance: CreditCardManager = CreditCardManager()
    static let creditCardID: String = "CREDIT_CARD_ID"
    static let creditCardType: String = "CREDIT_CARD_TYPE"
    static let creditCardLast4Digits: String = "CREDIT_CARD_4_DIGITS"

    let userDefaults = UserDefaults.standard

    func isThereACreditCardSaved() -> CreditCardResponse? {
        guard let id = userDefaults.string(forKey: CreditCardManager.creditCardID),
            let type = userDefaults.string(forKey: CreditCardManager.creditCardType),
            let last4Digits = userDefaults.string(forKey: CreditCardManager.creditCardLast4Digits) else {
            return nil
        }
        return CreditCardResponse(creditCardType: type, id: id, last4Digits: last4Digits)
    }

    func set(creditCard: CreditCardResponse) {
        userDefaults.setValue(creditCard.id, forKey: CreditCardManager.creditCardID)
        userDefaults.setValue(creditCard.creditCardType, forKey: CreditCardManager.creditCardType)
        userDefaults.setValue(creditCard.last4Digits, forKey: CreditCardManager.creditCardLast4Digits)
        userDefaults.synchronize()
    }

    func deleteCurrentCreditCard() {
        userDefaults.removeObject(forKey: CreditCardManager.creditCardID)
        userDefaults.removeObject(forKey: CreditCardManager.creditCardType)
        userDefaults.removeObject(forKey: CreditCardManager.creditCardLast4Digits)
    }
}

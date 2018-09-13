//
//  Double+Currency.swift
//  machApp
//
//  Created by Rodrigo Russell on 25/4/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

extension Double {

    func toCurrency(decimals: Int = 2) -> String {
        let formater = NumberFormatter()
        formater.groupingSeparator = "."
        formater.numberStyle = .decimal
        var formattedNumber = formater.string(from: NSNumber(floatLiteral: self.rounded(toPlaces: decimals))) ?? ""
        formattedNumber.insert("$", at: formattedNumber.startIndex)

        return formattedNumber
    }
}

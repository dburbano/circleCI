//
//  Int+currency.swift
//  machApp
//
//  Created by lukas burns on 5/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

extension Int {

    func toCurrency() -> String {
        let formater = NumberFormatter()
        formater.groupingSeparator = "."
        formater.numberStyle = .decimal
        var formattedNumber = formater.string(from: NSNumber(integerLiteral: self)) ?? ""
        formattedNumber.insert("$", at: formattedNumber.startIndex)

        return formattedNumber
    }
}

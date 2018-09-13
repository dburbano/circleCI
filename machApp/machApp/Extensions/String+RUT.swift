//
//  StringExtensions.swift
//  machApp
//
//  Created by lukas burns on 2/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

extension String {

    var isValidRut: Bool {

        let K = "K"

        var rut = self
        rut = rut.replacingOccurrences(of: ".", with: "")
        rut = rut.replacingOccurrences(of: "-", with: "")

        guard !rut.isEmpty else {
            return false
        }
        guard rut.length >= 8 else {
            return false
        }

        let dv = rut.removeLast().toString

        guard rut.isNumber() else {
            return false
        }
        guard dv.isNumber() || dv.uppercased() == K else {
            return false
        }

        let digits = rut.compactMap { Int(String($0)) }.reversed().enumerated()
        let sum = digits.reduce(0) {(sum, digit) in
            return sum + digit.element * (2 + digit.offset % 6 )
        }
        var code = 11 - (sum % 11)
        code = code == 11 ? 0 : code

        if code >= 0 && code <= 9 {
            return String(code) == dv
        }
        return dv.uppercased() == K
    }

    func toRutFormat() -> String {
        var rut = self
        if rut.contains("k") {
            rut = rut.replacingOccurrences(of: "k", with: "K", options: .literal, range: nil)
        }
        if rut.count == 9 {
            var formattedRut = rut
            formattedRut.insert("-", at: rut.index(rut.startIndex, offsetBy: 8))
            formattedRut.insert(".", at: rut.index(rut.startIndex, offsetBy: 5))
            formattedRut.insert(".", at: rut.index(rut.startIndex, offsetBy: 2))
            return formattedRut
        } else if rut.count == 8 {
            var formattedRut = rut
            formattedRut.insert("-", at: rut.index(rut.startIndex, offsetBy: 7))
            formattedRut.insert(".", at: rut.index(rut.startIndex, offsetBy: 4))
            formattedRut.insert(".", at: rut.index(rut.startIndex, offsetBy: 1))
            return formattedRut
        }
        return self
    }

}

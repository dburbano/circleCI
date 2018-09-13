//
//  String+Mach.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func convertToDecimal() -> Float {
        let formattedString: String = self.replacingOccurrences(of: ",", with: ".")
        let numberFromString: Float = (formattedString as NSString).floatValue
        return numberFromString
    }
    
    func htmlToString() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func firstLetter() -> String? {
        if !self.isEmpty {
            let firstLetterIndex = self.index(self.startIndex, offsetBy: 1)
            return String(self[..<firstLetterIndex]).capitalizedFirst()
        }
        return nil
    }
    
    func strikedThrough() -> NSAttributedString {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue])
        return attributedString
    }
    
    func separate(every: Int, with separator: String) -> String {
        return String(stride(from: 0, to: Array(self).count, by: every).map {
            Array(Array(self)[$0..<min($0 + every, Array(self).count)])
            }.joined(separator: separator))
    }
    
    func convertEndOfWord(with character: Character, percentage: Double) -> String {
        var responseString = self
        let length = responseString.count
        for (index, _) in responseString.enumerated() {
            
            if Double(index + 1) > Double(length) * percentage {
                let auxIndex = responseString.index(responseString.startIndex, offsetBy: index)
                responseString.replaceSubrange(auxIndex...auxIndex, with: "*")
            }
        }
        return responseString
    }
    
    func convertBeginingOfWord(with character: Character, percentage: Double) -> String {
        var responseString = self
        let length = responseString.count
        for (index, _) in responseString.enumerated() {
            
            if Double(index + 1) < Double(length) * percentage {
                let auxIndex = responseString.index(responseString.startIndex, offsetBy: index)
                responseString.replaceSubrange(auxIndex...auxIndex, with: "*")
            }
        }
        return responseString
    }
}


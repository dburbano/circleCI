//
//  String+Currency.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

extension String {
    static func clearTextFormat(text: String) -> String {
        return text.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ".", with: "")
    }
    
    func getRanges(of searchText:String) -> [NSRange] {
        var response = [NSRange]()
        let inputLength = self.count
        var range = NSRange(location: 0, length: self.count)
        
        while range.location != NSNotFound {
            range = self.toNSString.range(of: searchText, options: [], range: range)
            if range.location != NSNotFound {
                response.append(range)
                range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
            }
        }
        return response
    }
}

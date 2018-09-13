//
//  AddTaxableCountryRepository.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class AddTaxableCountryRepository: AddTaxableCountryRepositoryProtocol {

    lazy var countriesDictionary: [String: String] = {

        let locale = NSLocale.current as NSLocale
        let countryArray = NSLocale.isoCountryCodes
        var unsortedCountryDictionary = [String: String]()
        for countryCode in countryArray {
            let displayNameString = locale.displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
            if let displayNameString = displayNameString {
                unsortedCountryDictionary[displayNameString] = countryCode
            }
        }
        return unsortedCountryDictionary
        
        }()

    func getCountriesList(response: ([String: String]) -> Void) {
        response(countriesDictionary)
    }
}

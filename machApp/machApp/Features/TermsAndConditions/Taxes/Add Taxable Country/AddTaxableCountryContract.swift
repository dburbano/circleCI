//
//  AddTaxableCountryContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol AddTaxableCountryViewProtocol: class {
    func setupDropDown(withCountriesArray array: [String])
    func setDniTextfield(withString string: String)
    func add(taxableCountry: TaxableCountry)
    func enableAddCountryButton()
    func disableAddCountryButton()
}

protocol AddTaxableCountryPresenterProtocol: BasePresenterProtocol {
    func setView(view: AddTaxableCountryViewProtocol)
    func getCountries()
    func set(country: String)
    func set(dni: String)
    func addCountryPressed()
}

protocol AddTaxableCountryRepositoryProtocol {
    func getCountriesList(response: ([String: String]) -> Void)
}

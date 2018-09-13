//
//  AddTaxableCountryPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class AddTaxableCountryPresenter: AddTaxableCountryPresenterProtocol {

    weak var view: AddTaxableCountryViewProtocol?
    var repository: AddTaxableCountryRepositoryProtocol?

    var country: String?
    var dni: String?
    var countryDictionary: [String: String] = [:]

    required init(repository: AddTaxableCountryRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: AddTaxableCountryViewProtocol) {
        self.view = view
    }

    func getCountries() {
        repository?.getCountriesList(response: { (countries) in
            self.countryDictionary = countries
            view?.setupDropDown(withCountriesArray: Array(countries.keys).sorted())
        })
    }

    func set(country: String) {
        self.country = country
        self.validateCountryAndDni()
    }

    func set(dni: String) {
        self.dni = dni
        view?.setDniTextfield(withString: dni)
        self.validateCountryAndDni()
    }

    private func validateCountryAndDni() {
        guard let country = country, let dni = dni else {
            self.view?.disableAddCountryButton()
            return
        }
        if countryDictionary.has(country) && !dni.isBlank && !dni.isEmpty {
            self.view?.enableAddCountryButton()
        } else {
            self.view?.disableAddCountryButton()
        }
    }

    func addCountryPressed() {

        //Make sure both variables are not nil
        guard let  country = country else {
            return
        }

        //Make sure dni is not empty
        guard let dni = dni, !dni.isEmpty else {
            return
        }

        guard let countryCode = countryDictionary[country] else {
            return
        }

        view?.add(taxableCountry: TaxableCountry(country: country, dni: dni, countryCode: countryCode))
    }
}

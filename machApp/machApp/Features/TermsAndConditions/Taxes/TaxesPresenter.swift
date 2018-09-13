//
//  AboutTaxesPresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class TaxesPresenter: TaxesPresenterProtocol {

    let maximumCountriesAllowed: Int = 3
    var repository: TaxesRepositoryProtocol?

    var view: TaxesViewProtocol?
    var taxableCountries: [TaxableCountry] = []

    //When the view is created, the default status is Chile's taxes selected, and elsewhere not selected
    var isUserPayingTaxesInChile: Bool = true

    required init(repository: TaxesRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: TaxesViewProtocol) {
        self.view = view
    }

    func setupInitialState(selectedCountries: [TaxableCountry]) {
        self.taxableCountries = selectedCountries
        if taxableCountries.isEmpty {
            self.view?.setChileanTaxesSelected()
            self.view?.setForeignTaxesUnselected()
        } else {
            self.view?.setForeignTaxesSelected()
            self.view?.setChileanTaxesUnselected()
            isUserPayingTaxesInChile = false
        }
        self.showOrHideAddMoreCountriesOptions()
        self.view?.reloadData()
    }

    func paysChileanTaxesPressed() {
        self.isUserPayingTaxesInChile = true
        self.view?.setChileanTaxesSelected()
        self.view?.setForeignTaxesUnselected()
        self.view?.hideAddMoreCountries()
        self.taxableCountries.removeAll()
        self.view?.reloadData()
    }

    func paysForeignTaxesPressed() {
        isUserPayingTaxesInChile = false
        self.view?.setForeignTaxesSelected()
        self.view?.setChileanTaxesUnselected()
        self.view?.showAddMoreCountries()
    }

    func add(taxableCountry: TaxableCountry) {
        taxableCountries.append(taxableCountry)
        view?.reloadData()
        self.showOrHideAddMoreCountriesOptions()
    }

    func getTaxableCountries() -> [TaxableCountry] {
        return taxableCountries
    }

    func removeTaxableCountry(at index: IndexPath) {
        self.view?.askForCountryRemoval {
            self.taxableCountries.remove(at: index.row)
            self.view?.didRemoveCountry(at: index)
        }
    }

    private func showOrHideAddMoreCountriesOptions() {
        if taxableCountries.count >= maximumCountriesAllowed || isUserPayingTaxesInChile {
            self.view?.hideAddMoreCountries()
        } else {
            self.view?.showAddMoreCountries()
        }
    }

    func tableViewRemovedCell() {
        self.showOrHideAddMoreCountriesOptions()
    }
}

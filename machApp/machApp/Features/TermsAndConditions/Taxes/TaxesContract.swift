//
//  AboutTaxesContract.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

protocol TaxesViewProtocol {
    func setForeignTaxesSelected()
    func setChileanTaxesSelected()
    func setForeignTaxesUnselected()
    func setChileanTaxesUnselected()
    func reloadData()
    func didRemoveCountry(at index: IndexPath)
    func hideAddMoreCountries()
    func showAddMoreCountries()
    func askForCountryRemoval(onAccepted: @escaping () -> Void)
    func navigateBack()
}

protocol TaxesPresenterProtocol: BasePresenterProtocol {
    func setView(view: TaxesViewProtocol)
    func paysChileanTaxesPressed()
    func paysForeignTaxesPressed()
    func setupInitialState(selectedCountries: [TaxableCountry])
    func add(taxableCountry: TaxableCountry)
    func removeTaxableCountry(at index: IndexPath)
    func getTaxableCountries() -> [TaxableCountry]
    func tableViewRemovedCell()
}

protocol TaxesRepositoryProtocol {
}

protocol TaxesCellProtocol {
    func didPressDeleteTaxableCountry(cell: TaxableCountryViewCell)
}

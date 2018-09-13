//
//  TaxableCountryViewCell.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class TaxableCountryViewCell: UITableViewCell {

    var view: TaxesCellProtocol?
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var dniLabel: UILabel!

    func initialize(with taxableCountry: TaxableCountry) {
        countryLabel.text = taxableCountry.country
        dniLabel.text = taxableCountry.dni
    }

    @IBAction func didPressDeleteButton(_ sender: Any) {
        view?.didPressDeleteTaxableCountry(cell: self)
    }
}

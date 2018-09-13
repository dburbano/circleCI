//
//  AddTaxableCountryViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import DropDown

class AddTaxableCountryViewController: BaseViewController {

    // MARK: - Constants
    let dropdown: DropDown = DropDown()
    internal let showAboutTaxesSegue: String = "unwindtoAboutTaxesSegue"

    // MARK: - Outlets
    @IBOutlet weak var countryField: BorderTextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dniField: BorderTextField!
    @IBOutlet weak var addCountryButton: UIButton!

    // MARK: - Variables
    var presenter: AddTaxableCountryPresenterProtocol?
    var taxableCountry: TaxableCountry?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.getCountries()
        self.addCountryButton.addBorder(width: 1.0, color: Color.whiteTwo)

        self.addCountryButton.setTitleColor(Color.white, for: .normal)
        self.addCountryButton.setTitleColor(Color.whiteTwo, for: .disabled)

        self.addCountryButton.setBackgroundColor(Color.violetBlue, forState: .normal)
        self.addCountryButton.setBackgroundColor(UIColor.white, forState: .disabled)

        self.disableAddCountryButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createDropdownButton()
        customizeDropDown(dropdown)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == countryField {
            return false
        } else if textField == countryField {
            return false
        }
        return true
    }

    private func createDropdownButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icArrow-down"), for: .normal)
        //swiftlint:disable:next legacy_constructor
        button.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
        button.frame = CGRect(x: CGFloat(countryField.bounds.size.width - 22), y: CGFloat(6), width: CGFloat(18), height: CGFloat(18))
        button.imageView?.contentMode = .scaleAspectFit
        button.centerX = countryField.centerX
        button.addTarget(self, action: #selector(AddTaxableCountryViewController.showDropDown), for: .touchUpInside)
        countryField.rightViewRect(forBounds: button.frame)
        countryField.rightView = button
        countryField.rightViewMode = .always
    }

    @objc func showDropDown() {
        dropdown.show()
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == dniField {
            textField.resignFirstResponder()
            return true
        } else {
            return false
        }
    }

    private func customizeDropDown(_ sender: AnyObject) {
        let appearance = DropDown.appearance()

        appearance.cellHeight = 40
        appearance.backgroundColor = UIColor.white
        appearance.selectionBackgroundColor = Color.pinkishGrey
        //if we want a separator, uncomment the following
        //appearance.separatorColor = Color.warmGreyTwo
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.7
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = Color.greyishBrown
        //swiftlint:disable:next force_unwrapping
        appearance.textFont = UIFont(name: "Nunito-Regular", size: 16)!
    }

    // MARK: - Actions
    @IBAction func addCountryPressed(_ sender: Any) {
        presenter?.addCountryPressed()
    }

    @IBAction func dniTextFieldEditingChanged(_ sender: Any) {
        if let text = self.dniField.text {
            self.presenter?.set(dni: text)
        }
    }
}

extension AddTaxableCountryViewController: AddTaxableCountryViewProtocol {
    func setupDropDown(withCountriesArray array: [String]) {

        dropdown.anchorView = countryField.plainView
        dropdown.dataSource = array

        // Action triggered on-selection
        dropdown.selectionAction = { [unowned self] (index, item) in
            let country = self.dropdown.dataSource[index]
            self.countryField.text = country
            self.presenter?.set(country: country)
        }

        //lets initialize our dropdown at its first-value
        self.countryField.text = "Selecciona un país"
        dropdown.selectRow(at: 0)

    }

    func setDniTextfield(withString string: String) {
        dniField.text = string
    }

    func add(taxableCountry: TaxableCountry) {
        self.taxableCountry = taxableCountry
        performSegue(withIdentifier: showAboutTaxesSegue, sender: self)
    }

    func enableAddCountryButton() {
        self.addCountryButton.isEnabled = true
    }

    func disableAddCountryButton() {
        self.addCountryButton.isEnabled = false
    }
}

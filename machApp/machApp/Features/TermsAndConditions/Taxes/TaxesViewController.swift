//
//  AboutTaxesViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 8/1/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import ActiveLabel

class TaxesViewController: BaseViewController {

    // MARK: - Constants
    internal let showTaxesInformationSegue: String = "showTaxesInformationSegue"
    internal let showAddTaxableCountrySegue: String = "showAddTaxableCountrySegue"
    internal let showTermsAndConditions = "showTermsAndConditions"
 
    internal let taxableCountryViewCell = "TaxableCountryViewCell"

    internal let cellReuseIdentifier = "Cell"

    // MARK: - Variables
    var presenter: TaxesPresenterProtocol?
    var userInformation: UserIdentityVerificationInformation?
    var selectedTaxableCountries: [TaxableCountry] = []
    var accountMode: AccountMode?

    // MARK: - Outlets
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var chileanTaxesRadioButton: UIButton!
    @IBOutlet weak var foreignTaxesRadioButton: UIButton!
    @IBOutlet weak var taxableCountriesTable: UITableView!
    @IBOutlet weak var addOtherCountryButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    let subtitleLabel = ActiveLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitleLabel()
        configureTableView()
        presenter?.setupInitialState(selectedCountries: selectedTaxableCountries)
    }

    // MARK: - Setup

    func configureTitleLabel() {
        let customType = ActiveType.custom(pattern: "\\sResidencia Tributaria\\b")
        subtitleLabel.enabledTypes = [customType]
        subtitleLabel.numberOfLines = 0
        if let font = UIFont(name: "Nunito-Regular", size: 16) {
            subtitleLabel.font = font
        }
        subtitleLabel.text = "Por transparencia es importante declarar si además de Chile tienes Residencia Tributaria en otro país."
        subtitleLabel.textAlignment = .justified
        subtitleLabel.textColor = Color.warmGrey
        subtitleLabel.customColor[customType] = Color.brightSkyBlue
        subtitleLabel.customSelectedColor[customType] = Color.brightSkyBlue
        subtitleLabel.handleCustomTap(for: customType) {[unowned self] _ in
            self.performSegue(withIdentifier: self.showTaxesInformationSegue, sender: self)
        }
        titleStackView.addArrangedSubview(subtitleLabel)
    }

    func configureTableView() {
        taxableCountriesTable.register(UINib(nibName: taxableCountryViewCell, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
    }

    // MARK: - Actions

    @IBAction func goBackButtonPressed(_ sender: Any) {
        self.popVC()
    }

    @IBAction func didPressAddCountry(_ sender: Any) {
        performSegue(withIdentifier: showAddTaxableCountrySegue, sender: self)
    }

    @IBAction func chileanTaxesPressed(_ sender: Any) {
        presenter?.paysChileanTaxesPressed()
    }

    @IBAction func foreignTaxesPressed(_ sender: Any) {
        presenter?.paysForeignTaxesPressed()
        performSegue(withIdentifier: showAddTaxableCountrySegue, sender: self)
    }

    @IBAction func unwindToAboutTaxesVC(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddTaxableCountryViewController {
            if let taxableCountry = sourceViewController.taxableCountry {
                presenter?.add(taxableCountry: taxableCountry)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindFromTaxes", let destinationVC = segue.destination as? AcceptTermsAndConditionsViewController {
          destinationVC.selectedTaxableCountries = self.presenter?.getTaxableCountries() ?? []
        }
    }
}

//This protocol maybe will be used later
extension TaxesViewController: TaxesViewProtocol {

    func setForeignTaxesSelected() {
        foreignTaxesRadioButton.isSelected = true
        foreignTaxesRadioButton.isUserInteractionEnabled = false
    }

    func setChileanTaxesSelected() {
        chileanTaxesRadioButton.isSelected = true
        chileanTaxesRadioButton.isUserInteractionEnabled = false
    }

    func setForeignTaxesUnselected() {
        foreignTaxesRadioButton.isSelected = false
        foreignTaxesRadioButton.isUserInteractionEnabled = true
    }

    func setChileanTaxesUnselected() {
        chileanTaxesRadioButton.isSelected = false
        chileanTaxesRadioButton.isUserInteractionEnabled = true
    }

    func reloadData() {
        taxableCountriesTable.reloadData()
    }

    func didRemoveCountry(at index: IndexPath) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {[weak self] in
          self?.presenter?.tableViewRemovedCell()
        }
        taxableCountriesTable.beginUpdates()
        taxableCountriesTable.deleteRows(at: [index], with: .automatic)
        taxableCountriesTable.endUpdates()
        CATransaction.commit()
    }

    func hideAddMoreCountries() {
        addOtherCountryButton.isHidden = true
    }

    func showAddMoreCountries() {
        addOtherCountryButton.isHidden = false
    }

    func askForCountryRemoval(onAccepted: @escaping () -> Void) {
        self.showAlert(title: "Confirmar", message: "¿Estás seguro que deseas eliminar este país?", onAccepted: {
            onAccepted()
        }, onCancelled: {})
    }
    
    func navigateBack() {
        self.performSegue(withIdentifier: self.showTermsAndConditions, sender: self)
    }

}

extension TaxesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getTaxableCountries().count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TaxableCountryViewCell
        if let taxableCountry = presenter?.getTaxableCountries()[indexPath.row] {
            cell.view = self
            cell.initialize(with: taxableCountry)
        }
        return cell
    }
}

extension TaxesViewController: TaxesCellProtocol {
    func didPressDeleteTaxableCountry(cell: TaxableCountryViewCell) {
        if let indexPath = taxableCountriesTable.indexPath(for: cell) {
            presenter?.removeTaxableCountry(at: indexPath)
        }
    }
}

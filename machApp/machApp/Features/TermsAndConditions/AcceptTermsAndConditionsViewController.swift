//
//  AcceptTermsAndConditionsViewController.swift
//  machApp
//
//  Created by Lukas Burns on 11/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import ActiveLabel

enum TermsAndConditionsProcess {
    case register
    case generateCard
}

class AcceptTermsAndConditionsViewController: BaseViewController {

    let unwindFromTermsWithSuccess = "unwindFromTermsWithSuccess"
    let showTaxes = "showTaxes"
    let unwindFromTaxes = "unwindFromTaxes"
    let showRegisterUser = "showRegisterUser"

    var selectedTaxableCountries: [TaxableCountry] = []
    var termsAndConditionsProcess: TermsAndConditionsProcess?

    @IBOutlet weak var acceptTermsButton: LoadingButton!
    @IBOutlet weak var taxesLabel: ActiveLabel!

    // MARK: - Variables
    var presenter: AcceptTermsAndConditionsPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTaxesLabel()
        self.presenter?.termsAndConditionsProcess = self.termsAndConditionsProcess
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.acceptTermsButton.setAsActive()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func acceptTermsAndConditionsButtonTapped(_ sender: Any) {
        self.presenter?.termsAndConditionsAccepted()
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.popVC()
    }

    @IBAction func unwindToTermsAndConditions(segue: UIStoryboardSegue) {
        if segue.identifier == self.unwindFromTaxes {
            self.configureTaxesLabel()
            self.presenter?.setSelectedTaxes(selectedTaxableCountries: selectedTaxableCountries)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showTaxes, let destinationVC = segue.destination as? TaxesViewController {
            destinationVC.selectedTaxableCountries = self.selectedTaxableCountries
        } else if segue.identifier == self.unwindFromTermsWithSuccess, let destinationVC = segue.destination as? GeneratePrepaidCardViewController {
            destinationVC.isTermsAndConditionAccepted = true
        }
    }

    func configureTaxesLabel() {
        let customType = ActiveType.custom(pattern: "\\sCambiar\\b")
        taxesLabel.enabledTypes = [customType]
        
        if !selectedTaxableCountries.isEmpty {
            var countriesText = ""
            countriesText = selectedTaxableCountries.compactMap({ (country) -> String in
                country.country
            }).joined(separator: ", ")
            taxesLabel.text = "Al aceptar declaro que debo pagar impuestos en Chile y en \(countriesText). Cambiar"
        } else {
            taxesLabel.text = "Al aceptar declaro que debo pagar impuestos sólo en Chile. Cambiar"
        }
        taxesLabel.customColor[customType] = Color.brightSkyBlue
        taxesLabel.customSelectedColor[customType] = Color.brightSkyBlue
        taxesLabel.handleCustomTap(for: customType) {[unowned self] _ in
            self.performSegue(withIdentifier: self.showTaxes, sender: self)
        }
    }

}

extension AcceptTermsAndConditionsViewController: AcceptTermsAndConditionsViewProtocol {

    func navigateBackWithSuccess() {
        self.performSegue(withIdentifier: self.unwindFromTermsWithSuccess, sender: nil)
    }
    
    func disableRegisterButton() {
        self.acceptTermsButton.setAsLoading()
    }

    func enableRegisterButton() {
        if !self.acceptTermsButton.isEnabled {
            self.acceptTermsButton.setAsActive()
            self.acceptTermsButton.bloatOnce()
        }
    }
    
    func navigateToRegisterUser() {
        self.performSegue(withIdentifier: self.showRegisterUser, sender: nil)
    }
    
    func hideTaxesOption() {
        self.taxesLabel.isHidden = true
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }

}

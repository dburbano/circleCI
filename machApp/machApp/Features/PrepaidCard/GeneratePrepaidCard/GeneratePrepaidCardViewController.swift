//
//  GeneratePrepaidCardViewController.swift
//  machApp
//
//  Created by Lukas Burns on 4/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class GeneratePrepaidCardViewController: BaseViewController {
    
    let showTermsAndConditions: String = "showTermsAndConditions"
    let unwindFromTermsWithSuccess: String = "unwindFromTermsWithSuccess"
    let showGeneratingPrepaidCard: String = "showGeneratingPrepaidCard"
    let showPrepaidCard: String = "showPrepaidCard"

    var presenter: GeneratePrepaidCardPresenterProtocol?
    var isTermsAndConditionAccepted: Bool = false

    @IBOutlet weak var generateCardButton: LoadingButton!
    @IBOutlet weak var termsAndConditionsCheckBox: RoundedButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.presenter?.isTermsAndConditionsAccepted = isTermsAndConditionAccepted
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    @IBAction func generateCardButtonTapped(_ sender: Any) {
        self.presenter?.generateCard()
    }

    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.goBack()
    }
    
    @IBAction func termsAndConditionsCheckboxTapped(_ sender: Any) {
        self.presenter?.termsAndConditionsCheckboxPressed()
    }
    
    @IBAction func seeTermsAndConditionsButtonTapped(_ sender: Any) {
        self.presenter?.seeTermsAndConditions()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showTermsAndConditions, let destinationVC = segue.destination as? AcceptTermsAndConditionsViewController {
            destinationVC.termsAndConditionsProcess = TermsAndConditionsProcess.generateCard
        } else if segue.identifier == self.showGeneratingPrepaidCard, let destinationVC = segue.destination as? SecurityProcessViewController {
            destinationVC.securityRequestType = SecurityRequestType.prepaidCard
            destinationVC.delegate = self
        } else if segue.identifier == self.showPrepaidCard, let destinationVC = segue.destination as? PrepaidCardViewController, let prepaidCard = sender as? PrepaidCard {
            destinationVC.prepaidCard = prepaidCard
        }
    }
    
    @IBAction func unwindToGeneratePrepaidCard(segue: UIStoryboardSegue) {
        if segue.identifier == self.unwindFromTermsWithSuccess, segue.source is AcceptTermsAndConditionsViewController {
            self.presenter?.isTermsAndConditionsAccepted = self.isTermsAndConditionAccepted
        }
        print("Back to Generate Prepaid Card")
    }

}

extension GeneratePrepaidCardViewController: GeneratePrepaidCardViewProtocol {
    
    func goBack() {
        self.navigationController?.dismissVC(completion: nil)
    }
    
    func setGenerateButtonAsLoading() {
        self.generateCardButton?.setAsLoading()
    }

    func setGenerateButtonAsActive() {
        self.generateCardButton?.setAsActive()
    }
    
    func setGenerateButtonAsDisabled() {
        self.generateCardButton?.setAsInactive()
    }

    func setCheckboxAsSelected() {
        self.termsAndConditionsCheckBox.setBackgroundImage(#imageLiteral(resourceName: "checkboxChecked").tintImage(color: Color.violetBlue), for: .normal)
    }
    
    func setCheckboxAsUnselected() {
        self.termsAndConditionsCheckBox.setBackgroundImage(nil, for: .normal)
    }
    
    func navigateToGeneratingPrepaidCard() {
        print("Navigation from GeneratePrepaidCard")
        self.performSegue(withIdentifier: self.showGeneratingPrepaidCard, sender: self)
    }
    
    func navigateToPrepaidCard(with card: PrepaidCard) {
        print("YOYOYOYO")
        self.performSegue(withIdentifier: self.showPrepaidCard, sender: card)
    }

    func showNoInternetConnectionError() {

    }
    
    func showServerError() {

    }
    
}

extension GeneratePrepaidCardViewController: SecurityProcessDelegate {
    
    func successfullyFinished(with object: Any?) {
        if let prepaidCard = object as? PrepaidCard {
            self.navigateToPrepaidCard(with: prepaidCard)
        }
    }
}

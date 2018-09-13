//
//  TEFValidationInstructionViewController.swift
//  machApp
//
//  Created by Lukas Burns on 4/10/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class TEFValidationInstructionViewController: BaseViewController {
    
    let showTEFValidationDeposit: String = "showTEFValidationDeposit"
    let showTEFValidationAmountView: String = "showTEFValidationAmountView"
    let showSecuritySelfieInstructionsDialogue: String = "showSecuritySelfieInstructionsDialogue"
    var banks: [Bank] = []
    var presenter: TEFValidationInstructionPresenterProtocol?
    var goal: String?
    var challengeDelegate: ChallengeDelegate?
    var processResponse: ProcessResponse?
    
    @IBOutlet weak var startButton: LoadingButton!
    @IBOutlet weak var understandInstructionCheckbox: RoundedButton!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.areInstructionsUnderstood = false
        self.setupTexts()
        
        // Do any additional setup after loading the view.
    }

    private func setupTexts() {
        if let goal = AuthenticationGoal.init(rawValue: goal ?? "") {
            switch goal {
            case .prepaidCard:
                self.titleLabel.text = "Valida tu cuenta bancaria para obtener tu Tarjeta MACH"
            case .cashOutATM:
                self.titleLabel.text = "Valida tu cuenta bancaria para hacer retiros en cajeros"
            case .cashInTEF:
                self.titleLabel.text = "Valida tu cuenta bancaria para recargar MACH con transferencia"
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.setup()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: self.showTEFValidationDeposit, sender: nil)
    }
    
    @IBAction func dontHaveBankAccountButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: self.showSecuritySelfieInstructionsDialogue, sender: nil)
    }
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func understandInstructionTapped(_ sender: Any) {
        self.presenter?.understandInstructionCheckboxPressed()
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showTEFValidationDeposit, let destinationVC = segue.destination as? TEFValidationDepositViewController, let challengeDelegate = self.challengeDelegate, let processResponse = self.processResponse {
            destinationVC.presenter?.setChallenge(with: banks, process: processResponse, delegate: challengeDelegate)
        }
    }

    @IBAction func unwindToTEFValidationInstruction(segue: UIStoryboardSegue) {
        self.popVC()
    }

}

extension TEFValidationInstructionViewController: TEFValidationInstructionViewProtocol {
    func setStartButtonAsActive() {
        self.startButton?.setAsActive()
    }
    
    func setStartButtonAsDisabled() {
        self.startButton?.setAsInactive()
    }
    
    func setStartButtonAsLoading() {
        self.startButton?.setAsLoading()
    }
    
    func setCheckboxAsSelected() {
        self.understandInstructionCheckbox.setBackgroundImage(#imageLiteral(resourceName: "checkboxChecked").tintImage(color: Color.violetBlue), for: .normal)
    }
    
    func setCheckboxAsUnselected() {
        self.understandInstructionCheckbox.setBackgroundImage(nil, for: .normal)
    }
    
    func navigateToTEFValidationDeposit() {
        self.performSegue(withIdentifier: self.showTEFValidationDeposit, sender: nil)
    }
    
    func navigateToTEFValidationAmount(tefVerificationViewModel: TEFVerificationViewModel) {
        self.performSegue(withIdentifier: self.showTEFValidationAmountView, sender: tefVerificationViewModel)
    }
    
    func showNoInternetConnectionError() {
        // do nothing
    }
    
    func showServerError() {
        // do nothing
    }
    
}

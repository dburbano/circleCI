//
//  IdentityRecoveryResultViewController.swift
//  machApp
//
//  Created by lukas burns on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class IdentityRecoveryResultViewController: BaseViewController {

    // Constants
    let showStartIdentity: String = "showStartIdentity"

    // Variables
    var presenter: IdentityRecoveryResultPresenterProtocol?
    var identityRecoveryResultStatus: IdentityRecoveryResultStatus?
    var userViewModel: UserViewModel? {
        didSet {
            presenter?.userViewModel = userViewModel
        }
    }
    var accountMode: AccountMode?

    // Outlets
    @IBOutlet weak var resultStatusImageView: UIImageView!
    @IBOutlet weak var resultStatusLabel: UILabel!
    @IBOutlet weak var resultStatusInformationLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.setupResultStatus(identityRecoveryResultStatus: identityRecoveryResultStatus)
        self.continueButton.addTinyShadow()
        // Do any additional setup after loading the view.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    @IBAction func continueButtonPressed(_ sender: UIButton) {
        self.presenter?.continueButtonPressed()
    }

}

extension IdentityRecoveryResultViewController: IdentityRecoveryResultViewProtocol {

    func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    func navigateToStartIdentityRecovery() {
        performSegue(withIdentifier: showStartIdentity, sender: self)
    }

    func navigateToHome() {

    }

    func setupViewAsResultSuccess(with title: String, message: String, buttonMessage: String, imageName: String) {
        self.resultStatusImageView.image = UIImage(named: imageName)
        self.resultStatusLabel.text = title
        self.resultStatusInformationLabel.text = message
        self.continueButton.setTitle(buttonMessage, for: .normal)
    }

    func setupViewAsResultBlocked(with title: String, message: NSMutableAttributedString, buttonMessage: String, imageName: String) {
        self.resultStatusImageView.image = UIImage(named: imageName)
        self.resultStatusLabel.text = title
        self.resultStatusInformationLabel.attributedText = message
        self.continueButton.setTitle(buttonMessage, for: .normal)
    }

    func setupViewAsResultFailed(with title: String, message: String, buttonMessage: String, imageName: String) {
        self.resultStatusImageView.image = #imageLiteral(resourceName: "imageAccountFailed")
        self.resultStatusLabel.text = "No hemos podido validar tu identidad"
        self.resultStatusInformationLabel.text = "Puedes intentar responder las preguntas nuevamente"
        self.continueButton.setTitle("REINTENTAR", for: .normal)
    }

    func setupViewAsResultTooManyAttempts(with title: String, message: String, buttonMessage: String, imageName: String) {
        self.resultStatusImageView.image = #imageLiteral(resourceName: "imageAccountToManyAttempts")
        self.resultStatusLabel.text = "Demasiados intentos"
        self.resultStatusInformationLabel.text = "Vuelve a intentar en 24 horas."
        self.continueButton.setTitle("SALIR", for: .normal)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }
}

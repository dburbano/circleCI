//
//  StartIdentityRecoveryViewController.swift
//  machApp
//
//  Created by lukas burns on 5/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class StartSecurityQuestionsViewController: BaseViewController {

    // Constants
    let showIdentityRecovery: String = "showIdentityRecovery"

    // Variables
    var presenter: StartSecurityQuestionsPresenterProtocol?

    @IBOutlet weak var progressBar: ProgressBarView!
    // Outlets

    @IBOutlet weak var startRecoveryButton: LoadingButton!
    //@IBOutlet weak var userFirstNameLabel: UILabel!

    // Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewDidLoad()
        startRecoveryButton.addTinyShadow()
        self.progressBar?.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar.progressToNextStep()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    // Actions
    @IBAction func unwindToStartIdentity(segue: UIStoryboardSegue) {
        self.enableButton()
        print("Back to Start Identity")
    }

    @IBAction func notNowButtonPressed(_ sender: UIButton) {
        self.presenter?.cancelButtonPressed()
    }

    @IBAction func startRecoveryButtonPressed(_ sender: UIButton) {
        self.presenter?.startRecoveryPressed()
    }
}

extension StartSecurityQuestionsViewController: StartSecurityQuestionsViewProtocol {
    func setProgressBarSteps(currentStep: Int, totalSteps: Int) {
        self.progressBar?.currentStep = currentStep
        self.progressBar?.totalSteps = totalSteps
    }
    
    internal func goBackToRegisterDevice() {
        self.popToRootVC()
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    func enableButton() {
        self.startRecoveryButton.setAsActive()
    }

    func disableButton() {
        self.startRecoveryButton.setAsInactive()
    }

    func selectButton() {
        self.startRecoveryButton.setAsLoading()
    }
    
    func setName(fullName: String) {
        //self.userFirstNameLabel?.text = fullName
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }
}

//
//  LegalViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//
import UIKit

class LegalViewController: BaseViewController {

    // MARK: - Constants
    let showTermsAndConditionsDetail: String = "showTermsAndConditionsDetail"

    // MARK: - Variables
    var presenter: LegalPresenterProtocol?

    // MARK: - Outlets
    @IBOutlet weak var topView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Actions

    @IBAction func backTapped(_ sender: Any) {
        presenter?.navigateBackTapped()
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }

}

extension LegalViewController: LegalViewProtocol {

    func navigateBack() {
        self.popVC()
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }

}

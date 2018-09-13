//
//  ExecuteTransactionViewController.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import SDWebImage
import Lottie

class ExecuteTransactionViewController: BaseViewController {

    // MARK: - Constants
    let showHome: String = "showHome"
    let showHomeWithError: String = "showHomeWithError"
    let unwindToWithdrawATM: String = "unwindToWithdrawATM"
    let unwindToWithdrawATMWithSpecificError: String = "unwindToWithdrawATMWithSpecificError"
    let unwindToWithdrawATMWithGenericError: String = "unwindToWithdrawATMWithGenericError"
    let unwindToWithdrawTef: String = "unwindToWithdrawTef"
    
    // MARK: - Variables
    var presenter: ExecuteTransactionPresenterProtocol?
    var movementViewModel: MovementViewModel?
    var transactionMode: TransactionMode?
    var cashoutViewModel: CashoutViewModel?
    var cashoutATMViewModel: CashoutATMViewModel?

    weak var delegate: ExecuteOperationDelegate?
    lazy var spinnerAnimationView = LOTAnimationView(name: "animationSpinnerPayment")
    lazy var checkAnimationView = LOTAnimationView(name: "animationCheck")

    // MARK: - Outlets
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var userProfileImage: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var successMessageLabel: UILabel!
    
    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSpinnerAnimation()
        setupCheckAnimation()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.executeTransaction()
    }

    private func setupView() {
        self.presenter?.setMovementViewModel(movementViewModel)
        self.presenter?.setCashoutViewModel(cashoutViewModel)
        self.presenter?.setCashoutATMViewModel(cashoutATMViewModel)
        self.presenter?.setTransactionMode(transactionMode: transactionMode)
        
        self.view.setMachGradient(includesStatusBar: false, navigationBar: nil, withRoundedBottomCorners: false, withShadow: false)
        
        self.hideNavigationBar(animated: false)
    }
    
    private func setupSpinnerAnimation() {
        spinnerAnimationView.loopAnimation = true
        view.addSubview(spinnerAnimationView)
        
        spinnerAnimationView.translatesAutoresizingMaskIntoConstraints = false
        spinnerAnimationView.centerXAnchor.constraint(equalTo: userProfileImage.centerXAnchor).isActive = true
        spinnerAnimationView.centerYAnchor.constraint(equalTo: userProfileImage.centerYAnchor).isActive = true
        spinnerAnimationView.widthAnchor.constraint(equalTo: userProfileImage.widthAnchor, multiplier: 1.5).isActive = true
        spinnerAnimationView.heightAnchor.constraint(equalTo: userProfileImage.heightAnchor, multiplier: 1.5).isActive = true
       spinnerAnimationView.play()
    }
    
    private func setupCheckAnimation() {
        view.addSubview(checkAnimationView)
        checkAnimationView.isHidden = true
        
        checkAnimationView.translatesAutoresizingMaskIntoConstraints = false
        checkAnimationView.centerXAnchor.constraint(equalTo: userProfileImage.centerXAnchor).isActive = true
        checkAnimationView.centerYAnchor.constraint(equalTo: userProfileImage.centerYAnchor).isActive = true
        checkAnimationView.widthAnchor.constraint(equalTo: userProfileImage.widthAnchor, multiplier: 1.5).isActive = true
        checkAnimationView.heightAnchor.constraint(equalTo: userProfileImage.heightAnchor, multiplier: 1.5).isActive = true
    }
    
    private func executeTransaction () {
        self.presenter?.executeTransaction()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showHome,
            let destinationVC = segue.destination as? HomeViewController {
            destinationVC.newTransactionViewModel = sender as? TransactionViewModel
        } else if segue.identifier == showHomeWithError,
            let destinationVC = segue.destination as? HomeViewController {
            destinationVC.executeTransactionError = sender as? ExecuteTransactionError
        } else if let destinationVC = segue.destination as? WithdrawATMViewController {
            if segue.identifier == self.unwindToWithdrawATM,
                let cashoutATMResponse = sender as? CashoutATMResponse {
                destinationVC.cashoutATMResponse = cashoutATMResponse
            } else if segue.identifier == self.unwindToWithdrawATMWithGenericError,
                let error = sender as? ApiError {
                destinationVC.apiError = error
            } else if segue.identifier == self.unwindToWithdrawATMWithSpecificError,
                let error = sender as? ExecuteTransactionError {
                destinationVC.executeTransactionError = error
            }
        } else if segue.identifier == unwindToWithdrawTef,
            let destinationVC = segue.destination as? WithdrawTEFViewController,
            let transactionError = sender as? ExecuteTransactionError {
            destinationVC.transactionError = transactionError
        }
    }
}

extension ExecuteTransactionViewController: ExecuteTransactionViewProtocol {
    func showBlockedAction(with message: String) {
        delegate?.actionWasDeniedBySmyte(with: message)
    }

    func navigateToCashoutATMDetail(with cashoutATMResponse: CashoutATMResponse) {
        performSegue(withIdentifier: self.unwindToWithdrawATM, sender: cashoutATMResponse)
    }

    func navigateToCashoutATMDetail(with cashoutATMResponse: CashoutATMResponse, goToCreatedDialogue: Bool) {
        if goToCreatedDialogue {
            performSegue(withIdentifier: self.unwindToWithdrawATM, sender: cashoutATMResponse)
        } else {
            performSegue(withIdentifier: self.unwindToWithdrawATM, sender: cashoutATMResponse)
        }
    }

    internal func showInitialPaymentMessage() {
        self.successMessageLabel.text = "Enviando Pago..."
    }

    internal func showInitialRequestMessage() {
        self.successMessageLabel.text = "Enviando Cobro..."
    }

    internal func showInitialCashoutMessage() {
        self.successMessageLabel.text = "Solicitando Retiro..."
    }

    internal func showSuccessPaymentMessage() {
        self.successMessageLabel.text = "¡Pago Enviado!"
    }
    
    internal func hideSpinner() {
        spinnerAnimationView.removeFromSuperview()
        spinnerAnimationView.isHidden = true
    }
    
    internal func playCheckAnimation() {
        checkAnimationView.isHidden = false
        checkAnimationView.play()
    }

    internal func showSuccessRequestMessage() {
        self.successMessageLabel.text = "¡Cobro Enviado!"
    }

    internal func showSuccessCashoutMessage() {
        self.successMessageLabel.text = "¡Retiro Exitoso!"
    }

    func showFailedPaymentMessage() {
        self.successMessageLabel.text = "No se pudo realizar el pago"
    }

    func showPaymentError() {
        self.showToastWithText(text: NSLocalizedString("payment-service-error-message", comment: ""))
    }

    func showFailedRequestMessage() {
        self.successMessageLabel.text = "No se pudo realizar el cobro"
    }

    func showFailedCashoutMessage() {
        self.successMessageLabel.text = "No pudimos completar tu retiro"
    }

    func hideMessage() {
        self.successMessageLabel.text = ""
    }

    internal func navigateToChatDetail(with transaction: TransactionViewModel?) {
        self.performSegue(withIdentifier: self.showHome, sender: transaction)
    }

    internal func navigateToHome(with transactionError: ExecuteTransactionError) {
        self.performSegue(withIdentifier: self.showHomeWithError, sender: transactionError)
    }

    internal func navigateToHome() {
        self.performSegue(withIdentifier: self.showHomeWithError, sender: nil)
    }

    internal func navigateToSelectAmountCashoutATM(with transactionError: ExecuteTransactionError) {
        self.performSegue(withIdentifier: self.unwindToWithdrawATMWithSpecificError, sender: transactionError)
    }

    internal func navigateToSelectAmountCashoutATM(with apiError: ApiError) {
        self.performSegue(withIdentifier: self.unwindToWithdrawATMWithGenericError, sender: apiError)
    }

    internal func setAmount(amount: Int) {
        self.totalAmountLabel.text = amount.toCurrency()
    }

    internal func setUserImage(imageURL: URL?, placeHolder: UIImage?) {
        self.userProfileImage?.sd_setImage(with: imageURL, placeholderImage: placeHolder ?? #imageLiteral(resourceName: "placeholder-profile"))
    }

    internal func setUserName(firstName: String, lastName: String) {
        self.nameLabel.text = "\(firstName) \(lastName)"
    }

    internal func setLoadingMessage(message: String) {
        self.successMessageLabel.text = message
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: title, message: message, completion: onAccepted)
    }

    internal func closeView() {
        self.dismissVC(completion: nil)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }
    
    func navigateToWithdraw(with error: ExecuteTransactionError) {
        performSegue(withIdentifier: unwindToWithdrawTef, sender: error)
    }
}

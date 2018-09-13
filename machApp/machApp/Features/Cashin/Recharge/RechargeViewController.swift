//
//  RechargeViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/9/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class RechargeViewController: BaseViewController {

    // MARK: Constants
    let popToRootSegue = "popToRootSegue"
    let executeRechargeSegue = "executeRechargeSegue"
    let popToAddCreditCardSegue = "popToAddCreditCardSegue"
    let maximumNumberOfDigitsForAmount = 7
    let zendeskArticleName = "filter_cashintc"

    // MARK: Outlets
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var creditCardDigitsLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: BorderLabel!
    @IBOutlet weak var creditCardImage: UIImageView!
    @IBOutlet weak var rechargeAmountTextfield: BorderTextField!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var deleteCreditCardButton: UIButton!
    @IBOutlet weak var deleteCardActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var continueButton: LoadingButton!
    @IBOutlet var numericKeyboardToolbar: UIToolbar!

    // MARK: Variables
    var creditCard: CreditCardResponse?
    var presenter: RechargePresenterProtocol?
    var shouldPresentActionBlockedBySmyteTuple: (Bool, String?) = (false, nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rechargeAmountTextfield.becomeFirstResponder()
        presenter?.getBalance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldPresentActionBlockedBySmyteTuple.0 {
            let vc = SmyteBlockedActionViewController()
            vc.message = shouldPresentActionBlockedBySmyteTuple.1
            presentVC(vc)
            shouldPresentActionBlockedBySmyteTuple.0 = false
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        topContainer.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAmountField()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Actions
    @IBAction func didPressBack(_ sender: Any) {
        performSegue(withIdentifier: popToRootSegue, sender: nil)
    }

    @IBAction func didPressDeleteCard(_ sender: Any) {
        //swiftlint:disable:next force_unwrapping
        showAlert(with: "Quieres eliminar la tarjeta", message: creditCardDigitsLabel.text!, cancelMessage: "No por ahora", okMessage: "Sí, eliminar", okCompletion: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.hideButton(with: true)
            weakSelf.continueButton.setAsInactive()
            weakSelf.presenter?.deleteCreditCard()

        }, cancelCompletion: nil)
    }

    @IBAction func editingChanged(_ sender: Any) {
        if let text = rechargeAmountTextfield.text {
            let trimmedText = String.clearTextFormat(text: text)
            if trimmedText.isNumber() {
                presenter?.amountEdited(amount: Int(trimmedText))
            } else {
                continueButton.setAsInactive()
            }
        }
    }

    @IBAction func doneNumericKeyboardToolbarPressed(_ sender: Any) {
        rechargeAmountTextfield.resignFirstResponder()
    }

    @IBAction func didPressContinue(_ sender: Any) {
        //swiftlint:disable:next force_unwrapping
        presenter?.rechargeAccount(with: String.clearTextFormat(text: rechargeAmountTextfield.text!))
    }

    @IBAction func helpButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == executeRechargeSegue {
            let vc = segue.destination as? ExecuteRechargeViewController
            if let last4Digits = creditCardDigitsLabel.text, let amount = rechargeAmountTextfield.text, let id = creditCard?.id {
                vc?.data = (last4Digits, amount, id)
                vc?.executeOperationDelegate = self
            }
        }
    }

    @IBAction func unwindToRechargeCreditCard(segue: UIStoryboardSegue) { }

    // MARK: Private

    //swiftlint:disable:next function_parameter_count
    private func showAlert(with title: String, message: String, cancelMessage: String,
                           okMessage: String,
                           okCompletion: @escaping () -> Void,
                           cancelCompletion:(() -> Void)?) {
        let alertController = UIAlertController(title: title, message:  message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okMessage, style: .default) {[weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.setNeedsStatusBarAppearanceUpdate()
            okCompletion()
        })
        alertController.addAction(UIAlertAction(title: cancelMessage, style: .default) { [weak self] _ in
            self?.setNeedsStatusBarAppearanceUpdate()
            if let cancel = cancelCompletion {
                cancel()
            }
        })
        present(alertController, animated: true, completion: nil)
    }

    fileprivate func hideButton(with flag: Bool) {
        deleteCreditCardButton.isHidden = flag
        deleteCardActivityIndicator.isHidden = !flag
    }

    private func setup() {
        if let creditCard = creditCard {
            presenter?.creditCardResponse = creditCard
            presenter?.getCreditCardImageName(with: creditCard.creditCardType)
            presenter?.setCreditCardLabel(with: creditCard)
        }
        numericKeyboardToolbar.isTranslucent = false
        numericKeyboardToolbar.barTintColor = UIColor.init(gray: 247)
        rechargeAmountTextfield.inputAccessoryView = numericKeyboardToolbar
        continueButton.setAsInactive()
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goBackToRoot),
                                               name: .DidExecuteRecharge,
                                               object: nil)
    }

    @objc func goBackToRoot() {
        navigationController?.popToRootViewController(animated: false)
    }

    private func setupAmountField() {
        rechargeAmountTextfield.setupView()
    }

    // MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == rechargeAmountTextfield {
            guard let text = textField.text else { return false }
            // string.isEmpty is for the delete case
            return string.isEmpty ? true : text.count <= self.maximumNumberOfDigitsForAmount
        }
        return true
    }
}

extension RechargeViewController: RechargeViewProtocol {
    func updateAmount(with string: String) {
        rechargeAmountTextfield.text = string
    }

    func updateCreditCardLabel(with response: String) {
        creditCardDigitsLabel.text = response
    }

    func updateCreditCardImage(with imageName: String) {
        //swiftlint:disable:next force_unwrapping
        creditCardImage.image = UIImage(named: imageName)!
    }

    func updateBalance(balance: Int) {
        self.balanceLabel.text = balance.toCurrency()
        presenter?.balance = balance
    }

    func didDeleteCreditCard() {
        hideButton(with: false)
        if let vcs = navigationController?.viewControllers {
            let filteredVCs = vcs.filter({
                return $0 is AddCreditCardViewController
            })
            if filteredVCs.isEmpty {
                if let vc = UIStoryboard.init(name: "WebPay", bundle: nil).instantiateViewController(withIdentifier: "AddCreditCardViewController") as? AddCreditCardViewController {
                    navigationController?.pushViewController(vc, animated: true)
                     vc.navigationComesFromDeleteCreditCard = true
                }
            } else {
                performSegue(withIdentifier: popToAddCreditCardSegue, sender: nil)
            }
        }

    }

    func presentAmountError(with response: RechargePresenterResponse) {
        switch response {
        case .normal(let message):
            amountErrorLabel.text = message
            amountErrorLabel.textColor = Color.greyishBrown
            rechargeAmountTextfield.hideError()
            continueButton.setAsActive()
        case .overUpperBoundAmmount(let message), .withdraw(message: let message):
            amountErrorLabel.text = message
            amountErrorLabel.textColor = Color.redOrange
            rechargeAmountTextfield.showError()
            continueButton.setAsInactive()
        }
    }

    func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        guard let passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil).instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController else {
            return
        }
        passcodeViewController.successCallback = onSuccess
        passcodeViewController.failureCallback = onFailure

        passcodeViewController.setPasscode(passcodeMode: .transactionMode, title: "Ingresa tu PIN para confirmar la carga", optionText: "Cancelar")
        let navController = UINavigationController(rootViewController: passcodeViewController)
        navController.navigationBar.isHidden = true
        self.presentVC(navController)
    }

    func passcodeSuccesfull() {
        performSegue(withIdentifier: executeRechargeSegue, sender: nil)
    }

    func showNoInternetConnectionError() {
        hideButton(with: false)
        continueButton.setAsActive()
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        hideButton(with: false)
        continueButton.setAsActive()
        super.showGeneralErrorToast()
    }
}

extension RechargeViewController: ExecuteOperationDelegate {
    func actionWasDeniedBySmyte(with message: String) {
        shouldPresentActionBlockedBySmyteTuple = (true, message)
    }
}

//
//  PrepaidCardViewController.swift
//  machApp
//
//  Created by Lukas Burns on 3/19/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

protocol PrepaidCardHomeProtocol {
    func showRemovePrepaidCardDialogue()
}

class PrepaidCardViewController: BaseViewController {
    
    var presenter: PrepaidCardPresenterProtocol?
    var prepaidCard: PrepaidCard?

    let showPrepaidCardInformation: String = "showPrepaidCardInformation"
    let showRemovingPrepaidCard: String = "showRemovingPrepaidCard"
    let showPrepaidCardRemoveDialogueSegue: String = "showPrepaidCardRemoveDialogueSegue"
    let showHome: String = "showHome"
    let prepaidCardMenuTableSegue: String = "PrepaidCardMenuTableSegue"
    let unwindRemove: String  = "unwindRemove"

    @IBOutlet weak var topContainerView: UIView!

    @IBOutlet weak var amountLabel: UILabel!

    @IBOutlet weak var blurredOverlay: UIVisualEffectView!
    @IBOutlet weak var amountStackView: UIStackView!
    @IBOutlet weak var securityStackView: UIStackView!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var usdExchangeRateLabel: UILabel!
    @IBOutlet weak var balanceUSDLabel: UILabel!
    @IBOutlet weak var tipStackView: UIStackView!
    @IBOutlet weak var tipLabel: UILabel!
    
    var prepaidCardInformationViewController: PrepaidCardInformationViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.setup(prepaidCard: prepaidCard)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewWillLayoutSubviews() {
        self.topContainerView?.setMachGradient()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Actions

    @IBAction func unwindToPrepaidCardHome(segue: UIStoryboardSegue) {
        if segue.identifier == self.unwindRemove {
            self.presenter?.removePrepaidCard()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.prepaidCardMenuTableSegue, let destinationVC = segue.destination as? PrepaidCardMenuTableViewController {
            destinationVC.delegate = self
        } else if segue.identifier == self.showRemovingPrepaidCard, let destinationVC = segue.destination as? SecurityProcessViewController {
            destinationVC.securityRequestType = SecurityRequestType.removePrepaidCard
            destinationVC.delegate = self
        } else if segue.identifier == self.showPrepaidCardInformation, let destinationVC = segue.destination as? PrepaidCardInformationViewController {
            self.prepaidCardInformationViewController = destinationVC
            destinationVC.prepaidCard = self.prepaidCard
            destinationVC.presenter?.setDelegate(delegate: self.presenter!)
            self.presenter?.set(prepaidCardInformationPresenter: destinationVC.presenter)
        }
    }
}

extension PrepaidCardViewController: PrepaidCardViewProtocol {

    func updateBalance(balance: Int) {
        self.amountLabel?.text = balance.toCurrency()
    }

    func showBlurredOverlay() {
        self.blurredOverlay?.isHidden = false
    }

    func hideBlurredOverlay() {
        self.blurredOverlay?.isHidden = true
    }

    func showAmount() {
        self.amountStackView?.isHidden = false
    }

    func hideAmount() {
        self.amountStackView?.isHidden = true
    }

    func showTimer() {
        self.securityStackView?.isHidden = false
    }

    func hideTimer() {
        self.securityStackView?.isHidden = true
    }
    
    func showTip(with message: NSAttributedString?, flag: Bool) {
        if flag {
            tipStackView.isHidden = false
            guard let text = message else { return }
            tipLabel.attributedText = text
        } else {
            tipStackView.isHidden = true
        }
    }
    
    func updateTimer(with remainingSeconds: Int) {
        let minutes = remainingSeconds / 60 % 60
        let seconds = remainingSeconds % 60
        let remainingTime = String(format: "%02i:%02i", minutes, seconds)
        self.remainingTimeLabel?.text = "Datos visibles durante \(remainingTime)"
    }

    func updateExchangeRate(rate: Float) {
        self.usdExchangeRateLabel?.text = "Tipo cambio dólar \(Int(rate).toCurrency())"
    }

    func updateBalanceInUSD(usdBalance: Float) {
         self.balanceUSDLabel?.text = "En dólares \(usdBalance.toCurrency(decimals: 2)) USD"
    }

    func navigateToRemovingPrepaidCard() {
        self.performSegue(withIdentifier: self.showRemovingPrepaidCard, sender: self)
    }

    func navigateToHome() {
        self.performSegue(withIdentifier: self.showHome, sender: self)
    }

    internal func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void, with text: String) {
        guard let passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil).instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController else {
            return
        }
        passcodeViewController.successCallback = onSuccess
        passcodeViewController.failureCallback = onFailure
        passcodeViewController.setPasscode(passcodeMode: .transactionMode, title: text, optionText: "Cancelar")
        let navController = UINavigationController(rootViewController: passcodeViewController)
        navController.navigationBar.isHidden = true
        self.presentVC(navController)
    }

    func showNoInternetConnectionError() {
    }
    
    func showServerError() {
    }
}

extension PrepaidCardViewController: SecurityProcessDelegate {
    func successfullyFinished(with object: Any?) {
        self.navigateToHome()
    }
}

extension PrepaidCardViewController: PrepaidCardHomeProtocol {
    func showRemovePrepaidCardDialogue() {
        performSegue(withIdentifier: self.showPrepaidCardRemoveDialogueSegue, sender: nil)
    }
}

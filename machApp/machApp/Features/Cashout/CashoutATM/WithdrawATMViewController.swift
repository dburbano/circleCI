//
//  WithDrawATMViewController.swift
//  machApp
//
//  Created by Lukas Burns on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class WithdrawATMViewController: BaseViewController {

    // MARK: - Constants
    let cellIdentifier = "AmountCell"
    let showConfirmationDialogue = "showConfirmationDialogue"
    let showExecuteTransaction = "showExecuteTransaction"
    let showCashoutATMDetail = "showCashoutATMDetail"
    let showWithdrawMenu = "showWithdrawMenu"
    let showMaxWithdrawATMDialogueError = "showMaxWithdrawATMDialogueError"
    let unwindContinue = "unwindContinue"
    let unwindCancel = "unwindCancel"
    let unwindUnderstand = "unwindUnderstand"
    let zendeskArticleName = "filter_cashoutatm"
    let showMaxATMDailyCashOutDialogueError = "showMaxATMDailyCashOutDialogueError"

    // MARK: - Variables
    var presenter: WithdrawATMPresenterProtocol?
    var cashoutATMResponse: CashoutATMResponse?
    var executeTransactionError: ExecuteTransactionError?
    var apiError: ApiError?
    var errorMessageText = ""
    var errorMessageTitle = ""
    
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var topView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AmountTableViewCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let cashoutATMResponse = cashoutATMResponse {
            performSegue(withIdentifier: self.showCashoutATMDetail, sender: cashoutATMResponse)
        } else {
            self.presenter?.initialSetup()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.apiError != nil {
            self.showServerError()
            self.apiError = nil
        }
        if let executeTransactionError = self.executeTransactionError {
            switch executeTransactionError {
            case .cashoutMaxAttempts:
                self.navigateToMaxWithdrawATMDialogueError()
            case .cashoutATMDailyMaxAttempts(let message):
                self.navigateToMaxDailyATMCashOutDialogueError(message: message)
            default:
                self.showServerError()
            }
            self.executeTransactionError = nil
        }
    }

    // MARK: - Navigation
    @IBAction func unwindToWithdrawATM(segue: UIStoryboardSegue) {
        if segue.identifier == self.unwindContinue {
            self.presenter?.cashoutATMAccepted()
        } else if segue.identifier == self.unwindCancel {
            // Do nothing
        } else if segue.identifier == self.unwindUnderstand {
            // Do nothing
        } else if segue.identifier == nil {
            self.popVC()
        }
    }

    @IBAction func helpZendeskButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showExecuteTransaction, let cashoutATMViewModel = sender as? CashoutATMViewModel, let destinationVC = segue.destination as? ExecuteTransactionViewController {
            destinationVC.cashoutATMViewModel = cashoutATMViewModel
            destinationVC.transactionMode = TransactionMode.cashoutATM
        } else if segue.identifier == self.showCashoutATMDetail, let destinationVC = segue.destination as? WithdrawATMDetailViewController, let cashoutATMResponse = sender as? CashoutATMResponse {
            destinationVC.cashoutATMResponse = cashoutATMResponse
            destinationVC.amount = self.presenter?.getSelectedAmount()
        } else if segue.identifier == self.showMaxATMDailyCashOutDialogueError, let errorVC = segue.destination as? WithdrawATMErrorViewController {
            errorVC.titleLabelText = "Puedes retirar un máximo de $200.000 diarios"
            errorVC.buttonIsHidden = true
            guard let message = sender as? String else {
                return
            }
            errorVC.subtitleLabelText = message
        }
    }

    @IBAction func findNearATMButtonTapped(_ sender: Any) {
    }
}

extension WithdrawATMViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter?.getNumberOfAmountOptions() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! AmountTableViewCell
        if let amount = self.presenter?.getAmount(at: indexPath) {
            cell.setupCell(with: amount)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter?.amountSelected(at: indexPath)
    }

}

extension WithdrawATMViewController: WithdrawATMViewProtocol {
    func navigateToExecuteCashout(with cashoutATMViewModel: CashoutATMViewModel) {
        performSegue(withIdentifier: self.showExecuteTransaction, sender: cashoutATMViewModel)
    }
    
    func navigateToMaxWithdrawATMDialogueError() {
        performSegue(withIdentifier: self.showMaxWithdrawATMDialogueError, sender: nil)
    }

    func navigateToMaxDailyATMCashOutDialogueError(message: String) {
        performSegue(withIdentifier: self.showMaxATMDailyCashOutDialogueError, sender: message)
    }
    
    func updateBalance(balance: Int) {
        self.balanceLabel?.text = balance.toCurrency()
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func showConfirmationDialog() {
        if self.presenter?.getSelectedAmount() ?? 0 > self.presenter?.getBalance() ?? 0 {
            self.showToastWithText(text: "Woops, no tienes tanto saldo 🙄 Selecciona un monto más chico")
        } else {
            performSegue(withIdentifier: self.showConfirmationDialogue, sender: nil)
        }
    }

    func presentPasscode(onPINSuccessful: @escaping() -> Void, onPinFailure: @escaping() -> Void) {
        guard let passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil).instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController else {
            return
        }
        passcodeViewController.successCallback = onPINSuccessful
        passcodeViewController.failureCallback = onPinFailure

        passcodeViewController.setPasscode(
            passcodeMode: .transactionMode,
            title: "Ingresa tu PIN para confirmar el retiro de" +
                " \(self.presenter?.getSelectedAmount()?.toCurrency() ?? 0.toCurrency())",
            optionText: "Cancelar"
        )
        let navController = UINavigationController(rootViewController: passcodeViewController)
        navController.navigationBar.isHidden = true
        self.presentVC(navController)

    }

}

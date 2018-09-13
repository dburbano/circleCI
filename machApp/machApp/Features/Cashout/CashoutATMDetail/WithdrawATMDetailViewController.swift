//
//  WithdrawATMDetailViewController.swift
//  machApp
//
//  Created by Lukas Burns on 1/2/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class WithdrawATMDetailViewController: BaseViewController {

    // MARK: - Variables
    var presenter: WithdrawATMDetailPresenterProtocol!
    var cashoutATMResponse: CashoutATMResponse?
    var amount: Int?
    let unwindRemove = "unwindRemovedCashoutATM"
    let unwindCancel = "unwindCancel"
    let cashoutATMRemovedMessage = "cashoutATMRemovedMessage"
    let cashoutATMRemoveDialogue = "cashoutATMRemoveDialogue"
    let showCashoutATMCreatedDialogue = "showCashoutATMCreatedDialogue"
    let zendeskArticleName = "filter_cashoutatm"
    let hidePin = " · · · · ·"
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var expiredAtLabel: UILabel!
    @IBOutlet weak var containerInfoWithdraw: RoundedView!
    @IBOutlet weak var subContainerTimerInfo: UIView!
    @IBOutlet weak var headerTextStackView: UIStackView!
    @IBOutlet weak var footerTextTimeLabel: UILabel!
    @IBOutlet weak var footerTextTime: UIStackView!
    @IBOutlet weak var removeCashoutButton: UIButton!
    @IBOutlet weak var footerTextExpiredMessage: UILabel!
    @IBOutlet weak var createNewWithdrawButton: RoundedButton!
    @IBOutlet weak var seePinButton: RoundedButton!
    @IBOutlet weak var headerTextExpired: UILabel!
    @IBOutlet weak var headerTextBlocked: UILabel!
    @IBOutlet weak var payIdentityLabel: UILabel!
    @IBOutlet weak var redgiroPinLabel: UILabel!
    @IBOutlet weak var withdrawAmountLabel: UILabel!
    @IBOutlet weak var shareButtonTapped: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.initialSetup(cashoutATMResponse)
        if self.cashoutATMResponse?.expiredAt != nil {
            self.setDisabledDetailArea(expired: true)
        } else if self.cashoutATMResponse?.blockedAt != nil {
            self.setDisabledDetailArea(expired: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()

//        TODO!!
//        let rectShape = CAShapeLayer()
//        rectShape.bounds = subContainerTimerInfo.frame
//        rectShape.path = UIBezierPath(
//            roundedRect: subContainerTimerInfo.bounds,
//            byRoundingCorners: [.bottomLeft, .bottomRight],
//            cornerRadii: CGSize(width: 7, height: 7)
//        ).cgPath
//        subContainerTimerInfo.layer.mask = rectShape
//        subContainerTimerInfo.layer.backgroundColor = UIColor.red.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.showDialogueWhenWithdrawWasCreated()
    }
    
    @IBAction func onPressShowPin(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            self.pinLabel.text = self.hidePin
        }
    }
    
    @IBAction func onTouchDownShowPin(_ sender: Any) {
        self.pinLabel.text = self.presenter?.getPin()
    }
    
    @IBAction func onTouchDragOutsideShowPin(_ sender: Any) {
        self.pinLabel.text = self.hidePin
    }
    
    @IBAction func onTouchUpShowPin(_ sender: Any) {
         self.pinLabel.text = self.hidePin
    }

    @IBAction func helpZendeskButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }

    @IBAction func sendCashoutATMButtonTapped(_ sender: UIButton) {

        let firstActivityItem = "Estos son los datos para que puedas " +
            "retirar \(cashoutATMResponse?.amount.toCurrency() ?? "") en cualquier " +
            "cajero Bci 💸. Para hacer el retiro solo tienes que acercarte al cajero, " +
            "ingresar a la sección MACH y seguir los pasos. Tu código de retiro " +
            "es \(cashoutATMResponse?.nigCode ?? "") y la clave es \(cashoutATMResponse?.pin ?? "")."

        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem], applicationActivities: nil)

        activityViewController.excludedActivityTypes = [
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.airDrop,
            UIActivityType.postToFacebook
        ]

        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func removeCashoutButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: self.cashoutATMRemoveDialogue, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.cashoutATMRemoveDialogue,
            let destinationVC = segue.destination as? WithdrawRemoveCashoutConfirmViewController {
            destinationVC.cashoutATMResponse = self.cashoutATMResponse
        }
        if segue.identifier == self.showCashoutATMCreatedDialogue,
            let destinationVC = segue.destination as? WithdrawCreatedDialogueViewController {
            destinationVC.amount = (self.cashoutATMResponse?.amount)!
        }
    }

    @IBAction func unwindToWithdrawATMDetail(segue: UIStoryboardSegue) {
        if segue.identifier == self.unwindRemove {
            self.view?.isUserInteractionEnabled = false
            Thread.runOnMainQueue(1.0) {
                self.view?.isUserInteractionEnabled = true
                self.goToRemovedConfirmMessage()
            }
        } else if segue.identifier == self.unwindCancel {
            // Do nothing
        }
    }

}

extension WithdrawATMDetailViewController: WithdrawATMDetailViewProtocol {

    internal func setDisabledDetailArea(expired: Bool) {
        self.subContainerTimerInfo.layer.backgroundColor = UIColor.red.cgColor
        self.headerTextExpired.layer.isHidden = expired ? false : true
        self.headerTextBlocked.layer.isHidden = expired ? true : false
        self.footerTextExpiredMessage.layer.isHidden = false
        self.footerTextTime.layer.isHidden = true
        self.footerTextTimeLabel.layer.isHidden = true
        self.removeCashoutButton.layer.isHidden = true
        self.createNewWithdrawButton.layer.isHidden = false
        self.seePinButton.layer.isHidden = true
        self.headerTextStackView.layer.isHidden = true
        self.shareButtonTapped.layer.isHidden = true
        self.codeLabel.textColor = Color.pinkishGrey
        self.pinLabel.textColor = Color.pinkishGrey
        self.amountLabel.textColor = Color.pinkishGrey
        self.payIdentityLabel.textColor = Color.pinkishGrey
        self.redgiroPinLabel.textColor = Color.pinkishGrey
        self.withdrawAmountLabel.textColor = Color.pinkishGrey
    }

    func updateBalance(balance: Int) {
        self.balanceLabel?.text = balance.toCurrency()
    }

    func showNoInternetConnectionError() {

    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }

    func goToWithdrawMenu() {
        performSegue(withIdentifier: "unwindToWithdrawMenu", sender: nil)
    }

    func goToRemovedConfirmMessage() {
        performSegue(withIdentifier: self.cashoutATMRemovedMessage, sender: self)
    }

    func goToCashoutATMCreatedDialogue() {
        performSegue(withIdentifier: self.showCashoutATMCreatedDialogue, sender: nil)
    }
    
    func setCodeLabel(code: String) {
        self.codeLabel?.text = code.separate(every: 4, with: " ")
    }
    
    func setAmountLabel(amount: Int) {
        self.amountLabel.text = amount.toCurrency()
    }
    
    func setExpiredAtLabel(expiredAt: String) {
        self.expiredAtLabel.text = expiredAt
    }
}

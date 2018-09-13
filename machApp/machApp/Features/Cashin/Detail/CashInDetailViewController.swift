//
//  CashInDetailViewController.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/10/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class CashInDetailViewController: BaseViewController {

    // MARK: - Constants
    let spinner: SpinnerView = SpinnerView()
    let zendeskArticleName = "filter_cashintef"
    let zendeskArticleLink = "filter_restricciones"
    
    var accountInfo: AccountInformationResponse?

    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rutLabel: UILabel!
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    // MARK: - Variables
    var presenter: CashInDetailPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.getTipMessage()
        self.presenter?.accountInfo = self.accountInfo
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUpdatedBalance()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
        setupView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Actions
    @IBAction func shareData(_ sender: Any) {
        presenter?.shareData()
    }
    @IBAction func didPressBack(_ sender: Any) {
        self.popVC()
    }

    @IBAction func didPressHelp(_ sender: Any) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }
    
    @IBAction func didpressLink(_ sender: Any) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleLink])
    }

    // MARK: - Private

    private func getUpdatedBalance() {
        presenter?.getBalance()
    }

    private func setupView() {
        self.containerView.addTinyShadow()
    }
}

extension CashInDetailViewController: CashInDetailViewProtocol {
    internal func showTip(with message: NSAttributedString) {
        tipLabel.attributedText = message
    }
    
    internal func updateAccountInfo(info: AccountInformationResponse) {
        nameLabel.text = info.fullName
        rutLabel.text = info.rut
        bankLabel.text = info.bank
        accountTypeLabel.text = info.accountType
        accountNumberLabel.text = info.accountNumber
    }

    internal func updateBalance(balance: Int) {
        self.balanceLabel.text = balance.toCurrency()
    }

    internal func showSpinner() {
        spinner.presentInView(parentView: containerView)
    }

    internal func hideSpinner() {
        spinner.removeFromSuperview()
    }

    internal func shareData(withString string: String, excludedTypes: [UIActivityType]) {
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [string],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = excludedTypes

        self.present(activityViewController, animated: true, completion: nil)
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        showErrorMessage(title: "Error", message: message, completion: nil)
    }

    internal func showToastWhenCopied() {
        showToastWithText(text: "Copied to clipboard!")
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }
}

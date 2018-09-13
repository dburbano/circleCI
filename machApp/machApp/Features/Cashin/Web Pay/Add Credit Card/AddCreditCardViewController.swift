//
//  TestViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class AddCreditCardViewController: BaseViewController {

    // MARK: Constants
    let webViewSegue = "webViewSegue"
    let popToAddCreditCardSegue = "popToAddCreditCardSegue"
    let zendeskArticleName = "filter_cashintc"

    // MARK: Outlets
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addCreditCardButton: LoadingButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var toastDidDeleteCreditCard: UIView!

    // MARK: - Variables
    var presenter: AddCreditCardPresenterProtocol?
    var webPayResponse: WebPayURLResponse?
    var navigationComesFromDeleteCreditCard: Bool = false
    var shouldPresentActionBlockedBySmyteTuple: (Bool, String?) = (false, nil)
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.getBalance()
        addCreditCardButton.setAsActive()
        if navigationComesFromDeleteCreditCard {
            showDidDeleteCreditCardToast()
            navigationComesFromDeleteCreditCard = false
        }
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
        self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupButton()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: Actions
    @IBAction func didPressHelp(_ sender: Any) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }
    
    @IBAction func didPressBack(_ sender: Any) {
        performSegue(withIdentifier: "cashInSegue", sender: nil)
    }

    @IBAction func didPressAddCreditCard(_ sender: Any) {
        presenter?.getURLForWebView()
        addCreditCardButton.setAsLoading()
    }

    @IBAction func unwindToAddCreditCardFrom(segue: UIStoryboardSegue) {
        if segue.identifier == popToAddCreditCardSegue {
            showDidDeleteCreditCardToast()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewSegue {
            let webVC = segue.destination as? WebViewController
            webVC?.webUrlResponse = webPayResponse
            webVC?.executeOperationDelegate = self
        }
    }

    // MARK: Private
    private func setupButton() {
        addCreditCardButton.addDashedBorder()
        addCreditCardButton.layer.cornerRadius = 29.0
    }

    private func showDidDeleteCreditCardToast() {
        toastDidDeleteCreditCard.isHidden = false
        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseInOut, animations: {[weak self] in
            self?.toastDidDeleteCreditCard.alpha = 0.0
            }, completion: {[weak self] _ in
                self?.toastDidDeleteCreditCard.isHidden = true
                self?.toastDidDeleteCreditCard.alpha = 1.0
        })
    }
}

extension AddCreditCardViewController: AddCreditCardViewProtocol {
    func displayWebView(with webpayURLResponse: WebPayURLResponse) {
        webPayResponse = webpayURLResponse
        performSegue(withIdentifier: webViewSegue, sender: nil)
    }

    func updateBalance(balance: String) {
        balanceLabel.text = balance
    }

    func showNoInternetConnectionError() {
        addCreditCardButton.setAsActive()
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        addCreditCardButton.setAsActive()
        super.showGeneralErrorToast()
    }
}

extension AddCreditCardViewController: ExecuteOperationDelegate {
    func actionWasDeniedBySmyte(with message: String) {
        shouldPresentActionBlockedBySmyteTuple = (true, message)
    }
}

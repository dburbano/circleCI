//
//  CashInViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 10/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class CashInViewController: BaseViewController {

    //Outlets
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tefButton: LoadingButton!
    @IBOutlet weak var webPayButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var commissionClarificationLabel: UILabel!
    @IBOutlet weak var balanceClarificationLabel: UILabel!
    
    // MARK: Constants
    let cashInTefSegue: String = "showCashinTEF"
    let webPaySegueID: String = "showCashinWebPay"
    let rechargeSegue = "rechargeSegue"

    // MARK: - Variables
    var presenter: CashInPresenterProtocol?
    var isBackButtonHidden: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCommisionClarificationLabel()
        setupBalanceClarificationLabel()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.getBalance()
        self.backButton?.isHidden = isBackButtonHidden
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.topContainerView.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupButtons()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == rechargeSegue {
            let rechargeVC = segue.destination as? RechargeViewController
            rechargeVC?.creditCard = sender as? CreditCardResponse
        } else if segue.identifier == cashInTefSegue,
        let cashinVC = segue.destination as? CashInDetailViewController,
            let accountInfo = sender as? AccountInformationResponse {
            cashinVC.accountInfo = accountInfo
         }
    }

    // MARK: Actions
    @IBAction func didPressWebPay(_ sender: Any) {
        presenter?.getCreditCard()
    }

    @IBAction func unwindToCashInFrom(segue: UIStoryboardSegue) {}

    @IBAction func onBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressGetCashInInformation(_ sender: Any) {
        presenter?.getAccountInformation()
    }
    
    // MARK: Private

    private func setupButtons() {

        var cornerRadius = 29.0
        if UIDevice.hasSmallScreen() {
            cornerRadius = 20.0
        } else if UIDevice.hasMediumScreen() {
            cornerRadius = 25.0
        }
        tefButton.layer.cornerRadius = CGFloat(cornerRadius)
        webPayButton.addShadowChargeVC()
        webPayButton.layer.cornerRadius = CGFloat(cornerRadius)
    }
    
    private func setupCommisionClarificationLabel() {
        //We need to do this by code, because attributed strings are incompatible with emojis: Maybe this is a bug of Xcode
        let title = "MACH no cobra comisión por recarga ☺"
        let titleNSString = NSString.init(string: title)
        let attString = NSMutableAttributedString(string: title,
                                                  // swiftlint:disable:next force_unwrapping
                                                  attributes: [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 15.0)!,
                                                               NSAttributedStringKey.foregroundColor: Color.warmGrey])
        let range = titleNSString.range(of: "MACH")
        // swiftlint:disable:next force_unwrapping
        attString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Nunito-Bold", size: 15.0)!, range: range)
        commissionClarificationLabel.attributedText = attString
    }
    
    private func setupBalanceClarificationLabel() {
        let title = "El saldo de tu cuenta MACH es el mismo saldo de tu tarjeta MACH 💳"
        let ranges = title.getRanges(of: "MACH")
        let attrStr = NSMutableAttributedString(string: title,
                                                  // swiftlint:disable:next force_unwrapping
            attributes: [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 14.0)!,
                         NSAttributedStringKey.foregroundColor: Color.aquamarine])
        
        for range in ranges {
            // swiftlint:disable:next force_unwrapping
            attrStr.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Nunito-Bold", size: 15.0)!, range: range)
        }
        balanceClarificationLabel.attributedText = attrStr
    }
}

extension CashInViewController: CashInViewProtocol {

    func thereIsA(creditCard: CreditCardResponse) {
        performSegue(withIdentifier: rechargeSegue, sender: creditCard)
    }

    func thereIsNotACreditCard() {
       performSegue(withIdentifier: webPaySegueID, sender: nil)
    }

    func updateBalance(balance: String) {
        balanceLabel.text = balance
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }

    func navigateToStartAuthenticationProcess() {
        let storyboard = UIStoryboard(name: "AuthenticationProcess", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "StartAuthenticationProcessViewController") as? StartAuthenticationProcessViewController {
            viewController.goal = AuthenticationGoal.cashInTEF
            viewController.authenticationDelegate = self.presenter
            self.pushVC(viewController)
        }
    }
    
    func dismissAuthenticationProcess() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func navigateToCashInDetailWith(accountInfo: AccountInformationResponse) {
        self.performSegue(withIdentifier: self.cashInTefSegue, sender: accountInfo)
    }
    
    func setTefButtonAsLoading() {
        self.tefButton?.setAsLoading()
    }

    func setTefButtonAsActive() {
        self.tefButton?.setAsActive()
    }
    
    func closeAuthenticationProcess() {
        self.popVC()
    }
}

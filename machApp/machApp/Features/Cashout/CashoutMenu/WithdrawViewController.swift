//
//  WithdrawViewController.swift
//  machApp
//
//  Created by Lukas Burns on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class WithdrawViewController: BaseViewController {
    
    // MARK: - Constants
    fileprivate let showWithdrawTEF: String = "showWithdrawTEF"
    fileprivate let showWithdrawATM: String = "showWithdrawATM"
    fileprivate let showWithdrawATMDetail: String = "showWithdrawATMDetail"
    fileprivate let showWithdrawATMSavedAccount: String = "showWithdrawATMSavedAccount"
    fileprivate let showStartAuthenticationProcess: String = "showStartAuthenticationProcess"
    
    // MARK: - Variables
    var presenter: WithdrawPresenterProtocol!
    
    var isInContingency: Bool = false
   
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var topView: UIView!
//    @IBOutlet weak var withdrawTEFButton: UIButton!
    @IBOutlet weak var withdrawATMButton: LoadingButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contingencyInfoStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if isInContingency {
            self.showContingencyInformation()
            self.backButton?.isHidden = true
        }
        self.setBciLogoIconToButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.presenter?.initialSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()
    }
    
    func setBciLogoIconToButton() {
        let attachment: NSTextAttachment = NSTextAttachment()
        let bciImage = UIImage(named: "logoBciATM")
        attachment.image = bciImage
        attachment.bounds = CGRect(x: 0, y: -4, width: attachment.image?.size.width ?? 45, height: attachment.image?.size.height ?? 19)
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        let buttonText: NSMutableAttributedString = NSMutableAttributedString(string: " Retiro en cajero  ")
        buttonText.insert(attachmentString, at: buttonText.length)
        withdrawATMButton?.setAttributedTitle(buttonText, for: .normal)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWithdrawATMDetail" {
            guard let destination = segue.destination as? WithdrawATMDetailViewController else { return }
            guard let cashoutATMResponse = sender as? CashoutATMResponse else { return }
            destination.cashoutATMResponse = cashoutATMResponse
        } else if segue.identifier == "showWithdrawATMSavedAccount" {
            guard let destination = segue.destination as? WithdrawTEFSavedAccountViewController,
            let withdrawData = sender as? WithdrawData else { return }
            destination.withdrawData = withdrawData
        } else if segue.identifier == "showStartAuthenticationProcess" {
            guard let destination = segue.destination as? StartAuthenticationProcessViewController else { return }
            destination.authenticationDelegate = self.presenter
            destination.goal = AuthenticationGoal.cashOutATM
        }
    }
    
    @IBAction func unwindToWithdrawMenu(segue: UIStoryboardSegue) {}
    
    // MARK: - Actions
    
    @IBAction func withdrawTEFButtonTapped(_ sender: Any) {
        self.presenter?.withdrawTEFSelected()
    }
    
    @IBAction func withdrawATMButtonTapped(_ sender: Any) {
        self.presenter?.withdrawATMSelected()
    }
}

extension WithdrawViewController: WithdrawViewProtocol {
    
    func navigateToWithdrawATM() {
        performSegue(withIdentifier: self.showWithdrawATM, sender: nil)
    }

    func navigateToWithdrawATMDetail(cashoutATMResponse: CashoutATMResponse) {
        if cashoutATMResponse.completedAt != nil {
            performSegue(withIdentifier: self.showWithdrawATM, sender: nil)
        } else {
            performSegue(withIdentifier: self.showWithdrawATMDetail, sender: cashoutATMResponse)
        }
    }
    
    func navigateToWithdrawTEF() {
        performSegue(withIdentifier: showWithdrawTEF, sender: nil)
    }
    
    func navigateToStartAuthenticationProcess() {
        performSegue(withIdentifier: showStartAuthenticationProcess, sender: nil)
    }
    
    func navigateToWithdrawTEFSavedAccount(with withdrawData: WithdrawData) {
         performSegue(withIdentifier: showWithdrawATMSavedAccount, sender: withdrawData)
    }
    
    func updateBalance(balance: Int) {
        self.balanceLabel?.text = balance.toCurrency()
    }

    func setActiveWithdrawATMButton() {
        self.withdrawATMButton.setAsActive()
    }
    
    func setLoadingWithdrawATMButton() {
        self.withdrawATMButton.setAsLoading()
    }
    
    func changeTitle(to text: String) {
        self.titleLabel?.text = text
    }

    func hideBackButton() {
        self.backButton?.isHidden = true
    }

    func showBackButton() {
        self.backButton?.isHidden = false
    }

    func showContingencyInformation() {
        self.contingencyInfoStackView?.isHidden = false
    }

    func showNoInternetConnectionError() {}
    
    func showServerError() {
        super.showGeneralErrorToast()
    }
    
    func dismissAuthenticationProcess() {
        self.popVC()
    }
}

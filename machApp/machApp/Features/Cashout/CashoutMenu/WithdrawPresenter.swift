//
//  WithdrawPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class WithdrawPresenter: WithdrawPresenterProtocol {
    
    weak var view: WithdrawViewProtocol?
    var repository: WithdrawRepositoryProtocol?
    
    required init(repository: WithdrawRepositoryProtocol?) {
        self.repository = repository
    }
    
    // MARK: WithdrawPresenterProtocol
    func setView(view: WithdrawViewProtocol) {
        self.view = view
    }
    
    func initialSetup() {
        self.getBalanceAndUpdate()
    }
    
    func getBalanceAndUpdate() {
        if let balance = BalanceManager.sharedInstance.getBalance()?.balance {
            self.view?.updateBalance(balance: Int(balance))
        }
        self.repository?.getBalance(onSuccess: { (balanceResponse) in
            self.view?.updateBalance(balance: Int(balanceResponse.balance))
        }, onFailure: { (error) in
            self.handle(error: error)
        })
    }
    
    func setBciLogoIconToButton(button: LoadingButton){
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "logoBciATMBtn")
        attachment.bounds = CGRect(x: 0, y: 0, width: attachment.image?.size.width ?? 45, height: attachment.image?.size.height ?? 19)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: " Retiro en cajero  ")
        myString.insert(attachmentString, at: myString.length)
        button.setAttributedTitle(myString, for: .normal)
    }
    
    func withdrawTEFSelected() {
        //IF the user has made a succesfull cashout, we should have such account info 
        if let bankID = AccountManager.sharedInstance.getCashoutBank(),
            let accountNumber = AccountManager.sharedInstance.getCashoutAccountNumber(),
            let bankName = AccountManager.sharedInstance.getCashoutBankName() {
            let withdrawData = WithdrawData(bank: Bank(identifier: bankID, name: bankName), accountNumber: accountNumber)
            self.view?.navigateToWithdrawTEFSavedAccount(with: withdrawData)
        } else {
            self.view?.navigateToWithdrawTEF()
        }
    }
    
    func withdrawATMSelected() {
        // Analytics
        self.view?.setLoadingWithdrawATMButton()
        self.repository?.getWithdrawATMDetail(onSuccess: { (cashoutResponse) in
            self.view?.setActiveWithdrawATMButton()
            if cashoutResponse.cancelledAt != nil {
                self.view?.navigateToWithdrawATM()
            } else {
                self.view?.navigateToWithdrawATMDetail(cashoutATMResponse: cashoutResponse)
            }
        }, onFailure: { (error) in
            self.view?.setActiveWithdrawATMButton()
            self.handle(error: error, showDefaultError: true)
        })
    }
    
    //swiftlint:disable:next
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawError else { return }
            switch withdrawError {
            case .balance:
                break
            default:
                break
            }
        case .clientError(let withdrawError):
            guard let withdrawError = withdrawError as? WithdrawError else { return }
            switch withdrawError {
            case .balance:
                break
            case .cashoutATMNotFound:
                self.view?.navigateToWithdrawATM()
            case .userVerificationNeeded:
                self.view?.navigateToStartAuthenticationProcess()
            case .atmDailyAmountLimitExceeded:
                self.view?.navigateToWithdrawATM()
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
}

extension WithdrawPresenter: AuthenticationDelegate {
    func authenticationProcessClosed() {
        self.view?.dismissAuthenticationProcess()
    }
    
    func authenticationSucceeded() {
        self.view?.setLoadingWithdrawATMButton()
        self.view?.dismissAuthenticationProcess()
        self.withdrawATMSelected()
    }
    
    func authenticationFailed() {
        self.view?.dismissAuthenticationProcess()
    }
}

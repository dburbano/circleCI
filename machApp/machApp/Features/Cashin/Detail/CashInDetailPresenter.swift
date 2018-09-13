//
//  CashInDetailPresenter.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/10/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class CashInDetailPresenter: CashInDetailPresenterProtocol {
    
    weak var view: CashInDetailViewProtocol?
    var repository: CashInDetailRepositoryProtocol?
    var accountInfo: AccountInformationResponse? {
        didSet {
            guard let accountInfo = accountInfo else { return }
            self.view?.updateAccountInfo(info: accountInfo)
        }
    }

    required init(repository: CashInDetailRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: CashInDetailViewProtocol) {
        self.view = view
    }

    func getBalance() {
        self.repository?.getSavedBalance(response: {[weak self] (balance) in
            if let unwrappedBalance = balance, let unwrappedSelf = self {
                unwrappedSelf.view?.updateBalance(balance: Int(unwrappedBalance.balance))
            }
        })
        self.repository?.getBalance(onSuccess: { (balanceRessponse) in
            self.view?.updateBalance(balance: Int(balanceRessponse.balance))
        }, onFailure: { (cashInError) in
            self.handle(error: cashInError)
        })
    }

    func shareData() {
        if let tupleResponse = createInviteActivity() {
            view?.shareData(withString: tupleResponse.0, excludedTypes: tupleResponse.1)
        }
    }

    func copyToClipboard(string: String?) {
        UIPasteboard.general.string = string
        self.view?.showToastWhenCopied()
    }
    
    func getTipMessage() {
        repository?.fetchtipMessage(response: { [weak self] response in
            let title = response
            let titleNSString = NSString.init(string: title)
            let attString = NSMutableAttributedString(string: title,
                                                      // swiftlint:disable:next force_unwrapping
                attributes: [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 13.0)!,
                             NSAttributedStringKey.foregroundColor: Color.warmGrey])
            let range = titleNSString.range(of: "MACH")
            // swiftlint:disable:next force_unwrapping
            attString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Nunito-Bold", size: 13.0)!, range: range)
            self?.view?.showTip(with: attString)
        })
    }

    // MARK: - Private
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError :
            self.view?.showNoInternetConnectionError()
        case .serverError(let cashInError):
            guard let cashInError = cashInError as? CashInError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
        case .clientError(let cashInError):
            guard let cashInError = cashInError as? CashInError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }

    private func createInviteActivity() -> (String, [UIActivityType])? {
        guard let accountInfo = accountInfo else {
            return nil
        }
        let firstActivityItem = "\(accountInfo.fullName)\n\(accountInfo.rut)\nBanco \(accountInfo.bank)\n\(accountInfo.accountNumber)\nCuenta \(accountInfo.accountType)"
        let excludedTypes: [UIActivityType] =
            [.postToWeibo, .print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop]
        return (firstActivityItem, excludedTypes)
    }
}


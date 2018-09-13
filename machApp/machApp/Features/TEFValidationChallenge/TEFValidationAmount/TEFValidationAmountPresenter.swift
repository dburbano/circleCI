//
//  TEFValidationAmountPresenter.swift
//  machApp
//
//  Created by Rodrigo Russell on 16/4/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class TEFValidationAmountPresenter: TEFValidationAmountPresenterProtocol {

    weak var view: TEFValidationAmountViewProtocol?
    var repository: TEFValidationAmountRepositoryProtocol?
    var tefVerificationViewModel: TEFVerificationViewModel?
    var amount: Int?
    var challengeDelegate: ChallengeDelegate?
    var processResponse: ProcessResponse?

    required init(repository: TEFValidationAmountRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: TEFValidationAmountViewProtocol) {
        self.view = view
    }
    
    func setChallenge(with tefVerificationResponse: TEFVerificationResponse, process: ProcessResponse, delegate: ChallengeDelegate) {
        self.challengeDelegate = delegate
        self.processResponse = process
        self.tefVerificationViewModel = TEFVerificationViewModel(tefVerificationResponse: tefVerificationResponse)
    }

    func viewDidLoad() {
        self.view?.disableSendButton()
    }

    private func clearAmountTextFormat(text: String?) -> String {
        return text?.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ".", with: "") ?? ""
    }

    func amountChanged(amount: String?) {
        let cleanedAmount = self.clearAmountTextFormat(text: amount)
        if cleanedAmount.isNumber(), let amount = Int(cleanedAmount) {
            self.amount = amount
            self.view?.updateAmountTextField(amount: amount.toCurrency())
            if amount > 0 {
                self.view?.enableSendButton()
            } else {
                self.view?.disableSendButton()
            }
        } else {
            self.view?.updateAmountTextField(amount: "")
            self.view?.disableSendButton()
        }
        self.view?.showInputAmounInstruction()
    }

    func sendVerificationAmount() {
        guard tefVerificationViewModel?.status != TEFVerificationStatus.invalid else {
            self.view?.goBackToTEFValidationInstruction()
            return
        }
        guard let tefVerificationId = self.tefVerificationViewModel?.tefVerificationId else { return }
        guard let verificationAmount = self.amount else { return }
        self.view?.showInputAmounInstruction()
        let data = TEFVerificationCheck.init(tefVerificationId: tefVerificationId, amount: verificationAmount)
        self.view?.setSendButtonAsLoading()
        self.repository?.checkVerification(tefVerification: data, processId: self.processResponse?.id ?? "", onSuccess: { (authenticationResponse) in
            self.challengeDelegate?.didSucceedChallenge(authenticationResponse: authenticationResponse)
        }, onFailure: { (apiError) in
            self.view?.enableSendButton()
            self.handle(error: apiError)
        })
    }
    
    func tefDepositFailed() {
        self.view?.showInvalidTefDepositError(for: self.tefVerificationViewModel?.bankAccount ?? "")
        self.view?.disableAmountInput()
        self.tefVerificationViewModel?.status = .invalid
        self.view?.changeContinueButtonTextForCreateNewVerification()
        self.view?.enableSendButton()
    }

    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let error):
            print(error)
        case .clientError(let error):
            guard let tefValidationAmountError = error as? TEFValidationAmountError else { return }
            switch tefValidationAmountError {
            case .validationAttemptsLimitReached(_):
                self.view?.navigateToAttemptsDialogueError()
            case .validationAmount(_):
                self.view?.showIncorrectAmountError()
            }
            print(error)
        case .processFailedError(let errorMessage):
            self.challengeDelegate?.didProcessFailed(errorMessage: errorMessage)
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
}

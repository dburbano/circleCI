//
//  SelectAmountContract.swift
//  machApp
//
//  Created by lukas burns on 3/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

protocol SelectAmountViewProtocol: BaseViewProtocol {

    func updateUsers()

    func updateTotalAmount(totalAmount: Int)

    func updateBalance(balanceResponse: BalanceResponse)

    func clearTotalAmount()

    func enableConfirmationButton()

    func disableConfirmationButton()

    func navigateToExecuteTransaction()

    func navigateToExecuteRequestTransaction()

    func updateMessage(text: String)

    func presentPasscode(onSuccess: @escaping() -> Void, onFailure: @escaping() -> Void)

    func navigateBack()

    func showUnsufficientBalanceError()

    func showExceededAmountError()

    func hideUnsufficientBalanceError()

    func hideInputMessageView()

    func showTooltipCanChargeMore(with flag: Bool)

    func showTooltipCannotChargeMore(with flag: Bool)

    func showTooltipCantExceedMax(with flag: Bool)
    
    func showDivideTooltip(with flag: Bool)

    func updateTooltipCanChargeMoreLabel(with message: String)

    func setImage(image: UIImage?, imageURL: URL?, placeholderImage: UIImage?)

    func setUserAmountLabel(amount: Int)
    
    func showAddUserToCharge(with flag: Bool)
}

protocol SelectAmountPresenterProtocol: BasePresenterProtocol {

    var viewMode: ViewMode? { get set }

    func setView(view: SelectAmountViewProtocol)

    func getUser(for indexPath: IndexPath) -> UserAmountViewModel?

    func setUsers(_ userAmountViewModels: [UserAmountViewModel]?)

    func getAllUsers() -> [UserAmountViewModel]

    func totalAmountChanged(totalAmount: Int?)

    func totalAmountEditingEnd(totalAmount: Int?)

    func individualAmountChanged(for index: IndexPath, amount: Int?)

    func updateBalance()

    func getBalance() -> Int

    func messageSet(message: String)

    func passcodeSucceeded()

    func doneMessagePressed()

    func transactionConfirmed()

    func setTransactionMode(_ transactionMode: TransactionMode?)

    func getMovementViewModel() -> MovementViewModel?

    func setDefaultMessage(message: String)

    func backButtonPressed()

    func setProfileImage()

    func setSplitCountingUser(splitCountingUser: Bool)

    func getUserAmount() -> Int
}

protocol SelectAmountRepositoryProtocol {
    func getBalance(onSuccess: @escaping (BalanceResponse) -> Void, onFailure: @escaping (ApiError) -> Void)
    func getSavedBalance(response: (Balance?) -> Void)
}

enum SelectAmountError: Error {
    case failed(message: String)
    case obtainedBalanceFailed(message: String)
}

class SelectAmountErrorParser: ErrorParser {

    override func getError(networkError: NetworkError) -> ApiError {
        return super.getError(networkError: networkError)
    }
}

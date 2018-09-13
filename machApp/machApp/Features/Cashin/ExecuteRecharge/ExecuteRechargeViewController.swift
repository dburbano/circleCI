//
//  ExecuteRechargeViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

typealias RechargeViewInfo = (last4Digits: String, amount: String, creditCardID: String)

class ExecuteRechargeViewController: BaseViewController {

    // MARK: Constants
    let goHomeSegue = "goHomeSegue"
    let creditCardErrorSegue = "creditCardErrorSegue"
    let timeoutErrorSegue = "timeoutErrorSegue"
    let limitErrorSegue = "limitErrorSegue"
    let successSegue = "successSegue"

    // MARK: Outlets
    @IBOutlet weak var cardInfoLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var bottomTextLabel: UILabel!

    // MARK: Variables
    var presenter: ExecuteRechargePresenterProtocol?
    var data: RechargeViewInfo?
    weak var executeOperationDelegate: ExecuteOperationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if let data = data {
            presenter?.rechargeAccount(with: data)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == successSegue {
            guard let destinationVC = segue.destination as? CreditCardSuccessRechargeViewController,
            let value = sender as? String else { return }
            destinationVC.value = value
        }
    }

    // MARK: Private

    func setup() {
        view.setMachGradient(includesStatusBar: false, navigationBar: nil, withRoundedBottomCorners: false, withShadow: false)
        cardInfoLabel.text = data?.last4Digits
        amountLabel.text = data?.amount
    }
}

extension ExecuteRechargeViewController: ExecuteRechargeViewProtocol {

    func didRechargeCreditCard(with value: String) {
        //This is just a way around to a bug that sometimes inhibits the trigger of a segue
        DispatchQueue.main.asyncAfter(deadline: .now()) {[weak self] in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.performSegue(withIdentifier: unwrappedSelf.successSegue, sender: value)
        }

    }

    func navigateToCreditCardError() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {[weak self] in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.performSegue(withIdentifier: unwrappedSelf.creditCardErrorSegue, sender: nil)
        }

    }

    func navigateToTimeoutError() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {[weak self] in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.performSegue(withIdentifier: unwrappedSelf.timeoutErrorSegue, sender: nil)
        }
    }

    func showErrorAndDismiss() {
        bottomTextLabel.text = "No se ha podido realizar la carga"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    func navigateToLimitError() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {[weak self] in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.performSegue(withIdentifier: unwrappedSelf.limitErrorSegue, sender: nil)
        }
    }

    func showMessage(with text: String) {
        //TODO: Interesante validar que esta llegando a esta implementación y no a la implementación base
        super.showToastWithText(text: text)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    func showNoInternetConnectionError() {}

    func showServerError() {}

    func showBlockedAction(with message: String) {
        executeOperationDelegate?.actionWasDeniedBySmyte(with: message)
    }
    
    func closeView() {
        dismissVC(completion: nil)
    }
}

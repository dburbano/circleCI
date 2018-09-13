//
//  ExecuteRequestTransactionViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 3/6/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class ExecuteRequestTransactionViewController: BaseViewController {

    let cellIdentifier: String = "UserCell"
    let showHome: String = "showHome"
    let showHomeWithError: String = "showHomeWithError"

    var presenter: ExecuteRequestTransactionPresenterProtocol?
    var movementViewModel: MovementViewModel?

    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var successMessageLabel: UILabel!
    @IBOutlet weak var usersTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        if let movementViewModel = movementViewModel {
            self.totalAmountLabel.text = movementViewModel.totalAmount.toCurrency()
        }
//        self.presenter?.setMovementViewModel(movementViewModel)

        self.usersTableView.register(UINib(nibName: "UsersAmountTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.view.setMachGradient(includesStatusBar: false, navigationBar: nil, withRoundedBottomCorners: false, withShadow: false)

        self.hideNavigationBar(animated: false)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let movementViewModel = movementViewModel {
            self.presenter?.executeRequest(requestViewModel: movementViewModel)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Table View
extension ExecuteRequestTransactionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: self.cellIdentifier,
            for: indexPath
        ) as! UsersAmountTableViewCell

        if let movementViewModel = movementViewModel {
            cell.initializeWith(
                userAmountViewModel: movementViewModel.userAmountViewModels[indexPath.row]
            )
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movementViewModel = movementViewModel {
            return movementViewModel.userAmountViewModels.count
        }
        return 0
    }
}

extension ExecuteRequestTransactionViewController: UITableViewDelegate {

}

extension ExecuteRequestTransactionViewController: ExecuteRequestTransactionViewProtocol {
    func showServerError() {
        super.showGeneralErrorToast()
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showFailedRequestMessage() {
        self.successMessageLabel.text = "No se pudo realizar el cobro"
    }

    func showSuccessRequestMessage() {
        self.successMessageLabel.text = "¡Cobro Enviado!"
    }

    func closeView() {
        self.dismissVC(completion: nil)
    }

    func showMessage(with text: String) {
        //TODO: Interesante validar que esta llegando a esta implementación y no a la implementación base
        super.showToastWithText(text: text)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    internal func navigateToHome() {
        self.performSegue(withIdentifier: self.showHome, sender: nil)
    }
}

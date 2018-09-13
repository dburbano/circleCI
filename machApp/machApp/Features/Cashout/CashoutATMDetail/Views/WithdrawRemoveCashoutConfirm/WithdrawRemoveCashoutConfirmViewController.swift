//
//  WithdrawRemoveCashoutConfirmViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 1/30/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class WithdrawRemoveCashoutConfirmViewController: BaseViewController {

    var presenter: WithdrawRemoveCashoutConfirmPresenterProtocol!

    var cashoutATMResponse: CashoutATMResponse!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var buttonsStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loader.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmRemoveCashoutTapped(_ sender: RoundedButton) {
        self.loader.isHidden = false
        self.descriptionLabel.isHidden = true
        self.buttonsStack.isHidden = true
        self.titleLabel.text = "Eliminando retiro..."
        self.presenter?.removeCurrentCashoutATM(id: (self.cashoutATMResponse?.id)!)
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

extension WithdrawRemoveCashoutConfirmViewController: WithdrawRemoveCashoutConfirmViewProtocol {

    func showNoInternetConnectionError() {
        //
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func goToRemovedConfirmMessage() {
        performSegue(withIdentifier: "unwindRemovedCashoutATM", sender: nil)
    }
    
}

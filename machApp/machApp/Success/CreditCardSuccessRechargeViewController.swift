//
//  CreditCardSuccessRechargeViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/7/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class CreditCardSuccessRechargeViewController: UIViewController {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var continueButton: LoadingButton!

    var value: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.setAsActive()

        if let value = value {
            valueLabel.text = value
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    @IBAction func didPressContinue(_ sender: Any) {
        performSegue(withIdentifier: "goHomeSegue", sender: nil)
    }
}

//
//  CreditCardLimitViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class CreditCardLimitViewController: UIViewController {

    @IBOutlet weak var continueButton: LoadingButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.setAsActive()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

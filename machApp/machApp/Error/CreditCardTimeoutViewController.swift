//
//  CreditCardTimeoutViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class CreditCardTimeoutViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var goHomeButton: LoadingButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        goHomeButton.setAsActive()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

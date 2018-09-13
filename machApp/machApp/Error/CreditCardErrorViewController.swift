//
//  CreditCardErrorViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/21/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class CreditCardErrorViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var continueButton: LoadingButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.setAsActive()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

//
//  SimpleTermsAndConditionsViewController.swift
//  machApp
//
//  Created by lukas burns on 11/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class SimpleTermsAndConditionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func machLinkTapped(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "http://somosmach.com") {
            UIApplication.shared.openURL(url)
        }
    }

}

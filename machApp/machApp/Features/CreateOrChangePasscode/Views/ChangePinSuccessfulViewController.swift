//
//  ChangePinSuccessfulViewController.swift
//  machApp
//
//  Created by lukas burns on 9/14/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class ChangePinSuccessfulViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideNavigationBar(animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: true)
    }

    @IBAction func backButtonTap(_ sender: Any) {

    }
}

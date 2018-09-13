//
//  SmyteBlockedActionViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 2/20/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class SmyteBlockedActionViewController: BaseViewController {

    @IBOutlet weak var messageLabel: BorderLabel!
    @IBOutlet weak var continueButton: LoadingButton!

    var message: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.setAsActive()
        messageLabel.text = message
    }

    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

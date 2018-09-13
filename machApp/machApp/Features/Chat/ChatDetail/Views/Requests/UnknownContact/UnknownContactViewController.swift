//
//  UnknownContactViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 2/8/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class UnknownContactViewController: BaseViewController {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    var phoneNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberLabel.text = phoneNumber
    }

}

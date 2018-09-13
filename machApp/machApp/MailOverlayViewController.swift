//
//  MailOverlayViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 2/22/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

protocol MailOverlayDelegate: class {

    func didPressChangeMail()
    func didPressDoNotChangeMail()
}

class MailOverlayViewController: BaseViewController {

    let segueID = "unwindToProfile"

    weak var delegate: MailOverlayDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func didPressChangeMail(_ sender: Any) {
        delegate?.didPressChangeMail()
        performSegue(withIdentifier: segueID, sender: nil)
    }

    @IBAction func didPressDoNotChangeMail(_ sender: Any) {
        delegate?.didPressDoNotChangeMail()
        performSegue(withIdentifier: segueID, sender: nil)
    }
}

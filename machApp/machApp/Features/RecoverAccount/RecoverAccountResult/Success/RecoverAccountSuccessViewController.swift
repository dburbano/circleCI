//
//  RecoverAccountResultViewController.swift
//  machApp
//
//  Created by Lukas Burns on 5/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class RecoverAccountSuccessViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    let showGeneratePINNumber: String = "showGeneratePINNumber"
    
    var presenter: RecoverAccountSuccesssPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.getUserFirstName()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showGeneratePINNumber, let destinationVC = segue.destination as? GeneratePINNumberViewController {
            destinationVC.accountMode = AccountMode.recover
            destinationVC.generatePinMode = GeneratePinMode.create
        }
    }
}

extension RecoverAccountSuccessViewController: RecoverAccountSuccesssViewProtocol {
    func set(userFirstName: String) {
         messageLabel.text = "Bien \(userFirstName), sólo nos falta crear tu PIN de seguridad"
    }
}

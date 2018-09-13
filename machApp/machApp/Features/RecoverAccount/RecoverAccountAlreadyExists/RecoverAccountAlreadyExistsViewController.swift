//
//  RecoverAccountAlreadyExistsViewController.swift
//  machApp
//
//  Created by Lukas Burns on 5/14/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class RecoverAccountAlreadyExistsViewController: UIViewController {
    
    let showAuthenticationProcess = "showAuthenticationProcess"

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var continueButton: LoadingButton!
    
    var authenticationResponse: AuthenticationResponse?
    var authenticationDelegate: AuthenticationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userInformation = authenticationResponse?.challenge?.userInformation {
            self.userNameLabel?.text = userInformation.firstName
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: self.showAuthenticationProcess, sender: nil)
    }

     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showAuthenticationProcess, let destinationVC = segue.destination as? AuthenticationNavigationController, let authenticationResponse = self.authenticationResponse {
            destinationVC.challenge = authenticationResponse.challenge?.challenge
            destinationVC.process = authenticationResponse.process
            destinationVC.authenticationDelegate = self.authenticationDelegate
            destinationVC.saveUserInformation(info: authenticationResponse.challenge?.userInformation)
        }
    }

}

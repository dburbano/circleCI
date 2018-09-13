//
//  AuthenticationProcessErrorViewController.swift
//  machApp
//
//  Created by Santiago Balestero on 9/9/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class AuthenticationProcessErrorViewController: BaseViewController {
    
    @IBOutlet weak var goToStartButton: RoundedButton!
    
    var challengeDelegate: ChallengeDelegate?
    var processDelegate: AuthenticationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func understandButtonPressed(_ sender: UIButton) {
        processDelegate?.authenticationProcessClosed()
    }
}

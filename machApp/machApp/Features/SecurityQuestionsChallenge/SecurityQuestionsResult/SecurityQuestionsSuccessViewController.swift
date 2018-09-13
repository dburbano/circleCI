//
//  SecurityQuestionsSuccessViewController.swift
//  machApp
//
//  Created by Lukas Burns on 5/11/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class SecurityQuestionsSuccessViewController: UIViewController {
    
    var authenticationResponse: AuthenticationResponse?
    weak var challengeDelegate: ChallengeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if let authenticationResponse = self.authenticationResponse {
            self.challengeDelegate?.didSucceedChallenge(authenticationResponse: authenticationResponse)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

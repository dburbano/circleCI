//
//  StartAuthenticationProcessViewController.swift
//  machApp
//
//  Created by Santiago Balestero on 8/21/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class StartAuthenticationProcessViewController: BaseViewController {
    
    //Outlets
    @IBOutlet weak var continueButton: LoadingButton!
   
    let showAuthenticationProcess = "showAuthenticationProcess"
    var goal: AuthenticationGoal?
    var presenter: StartAuthenticationProcessPresenterProtocol?
    var authenticationDelegate: AuthenticationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Actions
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.authenticationDelegate?.authenticationProcessClosed()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        self.presenter?.startAuthenticationProcessChallenge(goal: goal!)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showAuthenticationProcess, let destinationVC = segue.destination as? AuthenticationNavigationController, let authenticationResponse = sender as? AuthenticationResponse {
            destinationVC.challenge = authenticationResponse.challenge?.challenge
            destinationVC.process = authenticationResponse.process
            destinationVC.authenticationDelegate = self.authenticationDelegate
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
}

extension StartAuthenticationProcessViewController: StartAuthenticationProcessViewProtocol {
    
    func beginAuthenticationProcess(with authenticationResponse: AuthenticationResponse ) {
        self.performSegue(withIdentifier: showAuthenticationProcess, sender: authenticationResponse)
    }
    
    func enableContinueButton() {
        continueButton?.setAsActive()
    }
    
    func setContinueButtonLoading() {
        self.continueButton?.setAsLoading()
    }

    func showNoInternetConnectionError() {}
    
    func showServerError() {}
    
}

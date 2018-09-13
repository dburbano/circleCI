//
//  ChallengeNavigationController.swift
//  machApp
//
//  Created by Lukas Burns on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

protocol AuthenticationDelegate {
    
    func authenticationSucceeded()
    func authenticationFailed()
    func authenticationProcessClosed()
}

enum Challenge {
    case requestPhoneVerification()
    case validatePhoneNumber(PhoneNumberRegistrationChallengeResponse)
    case requestEmail()
    case checkEmail(EmailChallengeResponse)
    case requestSecurityQuestions()
    case checkSecurityQuestions(SecurityQuestionsVerificationResponse)
    case documentIdVerification(String) // (rut)
    case requestTef([Bank])
    case checkTef(TEFVerificationResponse)
}

enum AuthenticationGoal: String {
    case prepaidCard = "get-prepaid-card"
    case cashInTEF = "get-account-data"
    case cashOutATM = "cash-out-atm"
}

class AuthenticationNavigationController: UINavigationController {
    
    // MARK: -Variables
    var challenge: Challenge?
    var process: ProcessResponse?
    var authenticationDelegate: AuthenticationDelegate?
    let challengeVCFactory = ChallengeViewControllerFactory()
    let showGeneralError: String = "showGeneralError"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let process = self.process, process.completed {
            self.processSucceeded()
        } else {
            self.navigateToNextChallenge()
        }
    }
    
    func navigateToNextChallenge() {
        guard let challenge = self.challenge, let process = self.process else { return }
        guard let nextViewController = self.challengeVCFactory.getViewController(challenge: challenge, processResponse: process, challengeDelegate: self) else { return }
        self.setViewControllers([nextViewController], animated: true)
    }
    
    func processSucceeded() {
        authenticationDelegate?.authenticationSucceeded()
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveUserInformation(info: UserInformationChallengeResponse?) {
        guard let info = info else { return }
        AccountManager.sharedInstance.set(rut: info.rut)
        AccountManager.sharedInstance.set(userFirstName: info.firstName)
        AccountManager.sharedInstance.set(userLastName: info.lastName)
    }
    
    func navigateToTefAmountError() {
        let viewController = UIStoryboard.init(name: "TEFValidation", bundle: nil).instantiateViewController(withIdentifier: "BlockValidationError") as? TEFValidationFailedViewController
        self.setViewControllers([viewController!], animated: true)
    }
    
    func navigateToGeneralError() {
        self.performSegue(withIdentifier: self.showGeneralError, sender: nil)
    }
    
    func navigateToRecoverAccountError() {
        let viewController = UIStoryboard.init(name: "RecoverAccount", bundle: nil).instantiateViewController(withIdentifier: "RecoverAccountFailedViewController") as? RecoverAccountFailedViewController
        self.setViewControllers([viewController!], animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showGeneralError, let destinationVC = segue.destination as? AuthenticationProcessErrorViewController {
            destinationVC.processDelegate = self.authenticationDelegate
        }
    }
}

extension AuthenticationNavigationController: ChallengeDelegate {
    
    func didSucceedChallenge(authenticationResponse: AuthenticationResponse) {
        self.saveUserInformation(info: authenticationResponse.challenge?.userInformation)
        self.process = authenticationResponse.process
        self.challenge = authenticationResponse.challenge?.challenge
        if authenticationResponse.process.completed {
            self.processSucceeded()
        } else {
            self.navigateToNextChallenge()
        }
    }
    
    func didProcessFailed(errorMessage: String) {
        self.navigateToGeneralError()
    }
    
    func didClosedChallenge() {
        self.dismiss(animated: true, completion: nil)
        self.authenticationDelegate?.authenticationProcessClosed()
    }
}

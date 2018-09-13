//
//  ChallengeFactory.swift
//  machApp
//
//  Created by Lukas Burns on 5/8/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class ChallengeViewControllerFactory {
    
    func getViewController(challenge: Challenge, processResponse: ProcessResponse, challengeDelegate: ChallengeDelegate) -> UIViewController?  {
        switch challenge {
            
        case .documentIdVerification(let rut):
            return createVerificationVCInstance(with: processResponse, rut: rut, delegate: challengeDelegate)
            
        case .requestSecurityQuestions():
            return createSecurityQuestionsVCInstance(with: processResponse, delegate: challengeDelegate)
            
        case .checkSecurityQuestions(let securityQuestionsResposne):
            return createEquifaxVCInstance(with: securityQuestionsResposne, process: processResponse, delegate: challengeDelegate)
            
        case .requestPhoneVerification:
            return createPhoneNumberRegistrationVCInstance(with: processResponse, delegate: challengeDelegate)
            
        case .validatePhoneNumber(let phoneRegistrationResponse):
            return createPhoneValidationVCInstance(with: phoneRegistrationResponse, processResponse: processResponse, delegate: challengeDelegate)
            
        case .requestEmail:
            return createEmailChallengeVCInstance(with: processResponse, delegate: challengeDelegate)
        
        case .checkEmail:
            return nil
            
        case .requestTef(let banks):
            let viewController = createTefValidationInstructionVCInstance(with: processResponse, delegate: challengeDelegate)
            viewController?.banks = banks
            viewController?.goal = processResponse.goal
            viewController?.challengeDelegate = challengeDelegate
            viewController?.processResponse = processResponse
            return viewController
            
        case .checkTef(let tefVerificationResponse):
            return createCheckTefValidationVCInstance(with: processResponse, delegate: challengeDelegate, tefVerificationResponse: tefVerificationResponse)
        }
        
    }
    
    private func createVerificationVCInstance(with process: ProcessResponse, rut: String, delegate: ChallengeDelegate) -> VerifyUserViewController? {
        guard let vc = UIStoryboard.init(name: "UserIdVerification", bundle: nil).instantiateViewController(withIdentifier: "VerifyUserViewController") as? VerifyUserViewController else { return nil }
        vc.accountMode = .recover
        vc.presenter?.setChallenge(for: process, with: rut, challengeDelegate: delegate)
        return vc
    }
    
    private func createSecurityQuestionsVCInstance(with process: ProcessResponse, delegate: ChallengeDelegate) -> StartSecurityQuestionsViewController? {
        guard let vc = UIStoryboard.init(name: "EquifaxChallenge", bundle: nil).instantiateViewController(withIdentifier: "StartSecurityQuestionsViewController") as? StartSecurityQuestionsViewController else { return nil }
        vc.presenter?.setChallenge(for: process, challengeDelegate: delegate)
        return vc
    }
    
    private func createEquifaxVCInstance(with securityResponse: SecurityQuestionsVerificationResponse, process: ProcessResponse, delegate: ChallengeDelegate) -> AnswerSecurityQuestionsPageViewController? {
        guard let securityVC = UIStoryboard.init(name: "EquifaxChallenge", bundle: nil).instantiateViewController(withIdentifier: "AnswerSecurityQuestionsPageViewController") as? AnswerSecurityQuestionsPageViewController else { return nil }
        securityVC.presenter?.setChallenge(for: process, challengeDelegate: delegate, securityQuestionsVerificationResponse: securityResponse)
        return securityVC
    }
    
    private func createPhoneNumberRegistrationVCInstance(with processResponse: ProcessResponse, delegate: ChallengeDelegate) -> RegisterPhoneNumberViewController? {
        guard let registerPhoneVC =  UIStoryboard.init(name: "PhoneNumberRegistration", bundle: nil).instantiateViewController(withIdentifier: "RegisterPhoneNumberViewController") as? RegisterPhoneNumberViewController else { return nil }
        registerPhoneVC.accountMode = .recover
        registerPhoneVC.presenter?.setChallenge(for: processResponse, with: delegate)
        return registerPhoneVC
    }
    
    private func createPhoneValidationVCInstance(with phoneRegistrationResponse: PhoneNumberRegistrationChallengeResponse, processResponse: ProcessResponse, delegate: ChallengeDelegate) -> ValidatePhoneNumberViewController? {
        guard let validatePhoneVC =  UIStoryboard.init(name: "PhoneNumberRegistration", bundle: nil).instantiateViewController(withIdentifier: "ValidatePhoneNumberViewController") as? ValidatePhoneNumberViewController else { return nil }
        validatePhoneVC.phoneNumber = phoneRegistrationResponse.phoneNumber
        validatePhoneVC.accountMode = .recover
        validatePhoneVC.presenter?.setChallenge(with: phoneRegistrationResponse, process: processResponse, delegate: delegate)
        return validatePhoneVC
    }
    
    private func createEmailChallengeVCInstance(with processResponse: ProcessResponse, delegate: ChallengeDelegate) -> EmailChallengeViewController? {
        guard let emailVC =  UIStoryboard.init(name: "EmailChallenge", bundle: nil).instantiateViewController(withIdentifier: "EmailChallengeViewController") as? EmailChallengeViewController else { return nil }
        emailVC.presenter?.setChallenge(for: processResponse, with: delegate)
        return emailVC
    }
    
    private func createTefValidationInstructionVCInstance(with processResponse: ProcessResponse, delegate: ChallengeDelegate) -> TEFValidationInstructionViewController? {
        guard let tefVC = UIStoryboard.init(name: "TEFValidation", bundle: nil).instantiateViewController(withIdentifier: "TEFValidationInstruction") as? TEFValidationInstructionViewController else { return nil }
        return tefVC
    }
    
    private func createCheckTefValidationVCInstance(with processResponse: ProcessResponse, delegate: ChallengeDelegate, tefVerificationResponse: TEFVerificationResponse) -> TEFValidationAmountViewController? {
        guard let tefAmountVC = UIStoryboard.init(name: "TEFValidation", bundle: nil).instantiateViewController(withIdentifier: "TEFValidationAmountViewController") as? TEFValidationAmountViewController else  { return nil }
        tefAmountVC.presenter?.setChallenge(with: tefVerificationResponse, process: processResponse, delegate: delegate)
        return tefAmountVC
    }
}

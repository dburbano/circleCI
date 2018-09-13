//
//  RecoverAccountPresenter.swift
//  machApp
//
//  Created by Lukas Burns on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

class RecoverAccountPresenter: RecoverAccountPresenterProtocol {

    var repository: RecoverAccountRepositoryProtocol?
    weak var view: RecoverAccountViewProtocol?
    
    var rut: String?
    
    required init(repository: RecoverAccountRepositoryProtocol?) {
        self.repository = repository
    }
    
    func set(view: RecoverAccountViewProtocol) {
        self.view = view
    }
    
    func rutEdited(_ text: String?) {
        self.rut = text?.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")
        self.view?.hideRutError()
        _ = self.isRutValid()
    }
    
    func continueButtonPressed() {
        self.view?.setContinueButtonAsLoading()
        self.repository?.registerDevice(deviceInformation: getDeviceInformation(),
            onSuccess: { () in
                //let appDelegate =  UIApplication.shared.delegate as? AppDelegate
                //appDelegate?.initializeSmyte()
                self.verifyRUTExists()
        }, onFailure: { [weak self] (error) in
            self?.view?.enableContinueButton()
            self?.handle(error: error)
        })
    }
    
    private func getDeviceInformation() -> DeviceRegistration {
        let deviceID = UIDevice.idForVendor()
        let systemVersion = UIDevice.systemVersion()
        let deviceModel = UIDevice.deviceModel()
        let deviceOS = "ios"
        return DeviceRegistration(deviceId: deviceID, deviceModel: deviceModel, systemVersion: systemVersion, deviceOS: deviceOS)
    }
    
    private func verifyRUTExists() {
        guard let rut = rut else { return }
        self.repository?.validateRUTExists(rut: rut, onSuccess: { (authenticationResponse) in
            AccountManager.sharedInstance.performLogOut(deleteTokens: false)
            self.view?.navigateToAccountAlreadyExists(with: authenticationResponse)
        }, onFailure: {[weak self] (error) in
            self?.view?.enableContinueButton()
            self?.handle(error: error)
        })
    }
    
    func rutEndEdited() {
        if !isRutValid() {
            self.view?.showIncorrectRutFormatError()
        } else {
            self.view?.hideRutError()
        }
    }
    
    func showHelp() {
        
    }
    
    private func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .unauthorizedError():
            break
        case .connectionError():
            self.view?.showNoInternetConnectionError()
        case .serverError(let recoverAccountError):
            guard let recoverAccountError = recoverAccountError as? RecoverAccountError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch recoverAccountError {
            default:
                break
            }
        case .clientError(let recoverAccountError):
            guard let recoverAccountError = recoverAccountError as? RecoverAccountError else { return }
            if showDefaultError {
                self.view?.showServerError()
            }
            switch recoverAccountError {
            case .accountNotFound:
                self.view?.showRutDoesntExistError()
                self.view?.disableContinueButton()
            }
        default:
            if showDefaultError {
                self.view?.showServerError()
            }
        }
    }
    
    private func isRutValid() -> Bool {
        if let rut = self.rut, rut.isValidRut {
            self.view?.enableContinueButton()
            return true
        } else {
            self.view?.disableContinueButton()
            return false
        }
    }
}

extension RecoverAccountPresenter: AuthenticationDelegate {
    func authenticationProcessClosed() {}

    func authenticationSucceeded() {
        // Navigate to Succeede screen
        self.view?.navigateToAccountRecoverySuccessfull()
        ////        // This VC should be passed from caller, for now only used to recover account so account recovery succes result is hardcoded here
        //        if let accountRecoverySuccessResult = UIStoryboard.init(name: "RecoverAccount", bundle: nil).instantiateViewController(withIdentifier: "RecoverAccountSuccessViewController") as? RecoverAccountSuccessViewController {
        //            self.setViewControllers([accountRecoverySuccessResult], animated: true)
        //        }
    }
    
    func authenticationFailed() {
        // Navigate to fail screen
        self.view?.navigateToAccountRecoveryFailed()
        //        if let accountRecoveryFailed = UIStoryboard.init(name: "RecoverAccount", bundle: nil).instantiateViewController(withIdentifier: "RecoverAccountFailedViewController") as? RecoverAccountFailedViewController {
        //            self.setViewControllers([accountRecoveryFailed], animated: true)
        //        }
    }
}

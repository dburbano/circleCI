//
//  RegisterDevicePresenter.swift
//  machApp
//
//  Created by lukas burns on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import EZSwiftExtensions

class RegisterDevicePresenter: RegisterDevicePresenterProtocol {

    weak var view: RegisterDeviceViewProtocol?
    var repository: RegisterDeviceRepositoryProtocol?
    
    var isTermsAndConditionsAccepted: Bool = false

    required init(repository: RegisterDeviceRepositoryProtocol?) {
        self.repository = repository
    }

    func setView(view: RegisterDeviceViewProtocol) {
        self.view = view
    }

    func registerAccount() {
        self.view?.setRegisterButtonAsLoading()
        SegmentAnalytics.Event.registrationStarted.track()
        self.repository?.registerDevice(deviceInformation: getDeviceInformation(),
        onSuccess: { () in
            //let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            //appDelegate?.initializeSmyte()
            self.acceptTermsAndConditions()
        }, onFailure: { (error) in
            self.view?.enableRegisterButton()
            self.handle(error: error)
        })
    }

    func recoverAccount() {
        self.view?.navigateToVerifyIdentity()
    }
    
    func seeTermsAndConditions() {
        self.repository?.registerDevice(deviceInformation: getDeviceInformation(),
            onSuccess: { () in
            //let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            //appDelegate?.initializeSmyte()
            self.view?.navigateToTermsAndConditions()
        }, onFailure: { (error) in
            self.handle(error: error, showDefaultError: true)
        })
    }
    
    func termsAndConditionsCheckboxPressed() {
        self.isTermsAndConditionsAccepted = !self.isTermsAndConditionsAccepted
        if self.isTermsAndConditionsAccepted {
            self.view?.setCheckboxAsSelected()
            self.view?.enableRegisterButton()
            self.view?.hideTermsAndConditionsTooltip()
        } else {
            self.view?.setCheckboxAsUnselected()
            self.view?.disableRegisterButton()
            self.view?.showTermsAndConditionsTooltip()
        }
    }
    
    func hasUserAcceptedTermsAndConditions() -> Bool {
        return isTermsAndConditionsAccepted
    }

    func acceptTermsAndConditions() {
        let chileanTax = TaxableCountry(country: "Chile", dni: "", countryCode: "CL")
        let termsAndConditionsAcceptance = TermsAndConditionsAcceptance(taxes: [chileanTax])
        self.repository?.acceptTermsAndConditions(termsAndConditionsAcceptance: termsAndConditionsAcceptance, onSuccess: {
            SegmentAnalytics.Event.termsAccepted.track()
            self.view?.navigateToRegisterUser()
        }, onFailure: { (error) in
            self.view?.enableRegisterButton()
            self.handle(error: error, showDefaultError: true)
        })
    }

    private func getDeviceInformation() -> DeviceRegistration {
        let deviceID = UIDevice.idForVendor()
        let systemVersion = UIDevice.systemVersion()
        let deviceModel = UIDevice.deviceModel()
        let deviceOS = "ios"
        return DeviceRegistration(deviceId: deviceID, deviceModel: deviceModel, systemVersion: systemVersion, deviceOS: deviceOS)
    }

    func handle(error apiError: ApiError, showDefaultError: Bool = false) {
        switch apiError {
        case .connectionError:
            self.view?.showNoInternetConnectionError()
        case .serverError(let registerDeviceError):
            guard let registerDeviceError = registerDeviceError as? RegisterDeviceError else { return }
            self.view?.showServerError()
            switch registerDeviceError {
            case .registerDeviceFailed:
                break
            }
        case .clientError(let registerDeviceError):
            guard let registerDeviceError = registerDeviceError as? RegisterDeviceError else { return }
            self.view?.showServerError()
            switch registerDeviceError {
            case .registerDeviceFailed:
                break
            }
        default:
            self.view?.showServerError()
        }
    }
}

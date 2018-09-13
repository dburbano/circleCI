//
//  IdentityRecoveryResultPresenter.swift
//  machApp
//
//  Created by lukas burns on 5/18/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

enum IdentityRecoveryResultStatus {
    case success
    case failed
    case blocked
    case tooManyAttempts
}

class IdentityRecoveryResultPresenter: IdentityRecoveryResultPresenterProtocol {
    
    weak var view: IdentityRecoveryResultViewProtocol?
    var repository: IdentityRecoveryResultRepositoryProtocol?
    var userViewModel: UserViewModel?
    
    var identityRecoveryResultStatus: IdentityRecoveryResultStatus?
    
    required init(repository: IdentityRecoveryResultRepositoryProtocol?) {
        self.repository = repository
    }
    
    func setView(view: IdentityRecoveryResultViewProtocol) {
        self.view = view
    }
    
    func setupResultStatus(identityRecoveryResultStatus: IdentityRecoveryResultStatus?) {
        self.identityRecoveryResultStatus = identityRecoveryResultStatus
        guard let resultStatus = identityRecoveryResultStatus else {
            //show Error
            return
        }
        switch resultStatus {
        case .success:
            self.view?.setupViewAsResultSuccess(with: "Cuenta recuperada con éxito", message: "Bien \(userViewModel?.machFirstName ?? ""), para terminar necesitamos validar tu número de teléfono y establecer un nuevo PIN", buttonMessage: "CONTINUAR", imageName: "imageAccountSuccess")
        case .failed:
            self.view?.setupViewAsResultFailed(with: "No hemos podido validar tu identidad", message: "Puedes intentar responder las preguntas nuevamente", buttonMessage: "REINTENTAR", imageName: "imageAccountFailed")
        case .blocked:
            let text =  "No hemos podido confirmar tu identidad y hemos bloqueado tu cuenta temporalmente. Puedes volver a intentarlo en 72 hrs.\n\nPara ver más opciones de recuperación escríbenos a ayuda@mach.cl"
            let stText = NSString.init(string: text)
            let attrString = NSMutableAttributedString(string: text,
                                                       attributes: [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 16.0)!,
                                                                    NSAttributedStringKey.foregroundColor: Color.warmGrey])
            let range = stText.range(of: "ayuda@mach.cl")
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.brightSkyBlue, range: range)
            self.view?.setupViewAsResultBlocked(with: "Cuenta bloqueada", message: attrString, buttonMessage: "SALIR", imageName: "imageAccountBlocked")
        case .tooManyAttempts:
            self.view?.setupViewAsResultTooManyAttempts(with: "Demasiados intentos", message: "Vuelve a intentar en 24 horas.", buttonMessage: "SALIR", imageName: "imageAccountToManyAttempts")
        }
    }
    
    func continueButtonPressed() {
        guard let resultStatus = identityRecoveryResultStatus else {
            //show Error
            return
        }
        switch resultStatus {
        case .success:
            break
        case .failed:
            self.view?.navigateToStartIdentityRecovery()
        case .blocked:
            self.view?.navigateToHome()
        case .tooManyAttempts:
            break
        }
    }
}

//
//  PinPresenter.swift
//  machApp
//
//  Created by lukas burns on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import Swinject

public class PasscodeManager {

    private var mainWindow: UIWindow?

    var backgroundTimerTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var hasTimerExpired: Bool?
    var updateTimer: Timer?
    let secondsBeforePinIsAskedAgain: Double = 60 * 5

    private lazy var passcodeLockWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = 0
        window.makeKeyAndVisible()
        return window
    }()

    private lazy var recoverAccountWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = 0
        window.makeKeyAndVisible()
        return window
    }()

    var isPasscodePresented = false
    let passcodeViewController: PasscodeViewController?

    public init(mainWindow window: UIWindow?) {
        passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil).instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController
        mainWindow = window
        passcodeViewController?.setPasscode(passcodeMode: .loginMode, title: "Ingresa tu PIN", optionText: "Olvidé mi PIN")
    }

    public func presentPasscode() {
        //guard let repository = passcodeRepository else { return }
        //guard repository.hasPasscode() else { return }
        guard AccountManager.sharedInstance.isLoggedIn() else { return }
        guard hasTimerExpired == nil || hasTimerExpired == true else {
            return
        }
        isPasscodePresented = true
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.isHidden = false
        passcodeViewController?.setTitle(text: "Ingresa tu PIN")

        mainWindow?.windowLevel = 1
        mainWindow?.endEditing(true)
        let userDismissCompletionCallback = passcodeViewController?.dismissCompletionCallback

        passcodeViewController?.dismissCompletionCallback = { [weak self] in
            userDismissCompletionCallback?()
            self?.dismissPasscode()
        }
        passcodeViewController?.successCallback = { [weak self] in
            print("Partiendo Timer")
            self?.startTimer()
        }
        //swiftlint:disable:next force_unwrapping
        passcodeLockWindow.rootViewController = UINavigationController(rootViewController: passcodeViewController!)
    }

    public func dismissPasscode(animated: Bool = true) {
        isPasscodePresented = false
        mainWindow?.windowLevel = 1
        mainWindow?.makeKeyAndVisible()

        if animated {
            animatePasscodeDismissal()
        } else {
            passcodeLockWindow.windowLevel = 0
            passcodeLockWindow.rootViewController = nil
        }
    }

    internal func animatePasscodeDismissal() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in

                self?.passcodeLockWindow.alpha = 0
            },
            completion: { [weak self] _ in

                self?.passcodeLockWindow.windowLevel = 0
                self?.passcodeLockWindow.rootViewController = nil
                self?.passcodeLockWindow.alpha = 1
            }
        )
    }

    func startTimer() {
        registerBackgroundTask()
        hasTimerExpired = false
        updateTimer = Timer.scheduledTimer(timeInterval: secondsBeforePinIsAskedAgain, target: self,
                                           selector: #selector(setTimerAsExpired), userInfo: nil, repeats: false)
    }

    @objc func setTimerAsExpired() {
        print("Expiro el tiempo")
        hasTimerExpired = true
        endBackgroundTask()
    }

    func registerBackgroundTask() {
        backgroundTimerTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            self?.endBackgroundTask()
        })
        assert(backgroundTimerTask != UIBackgroundTaskInvalid)
    }

    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTimerTask)
        backgroundTimerTask = UIBackgroundTaskInvalid
    }
}

//
//  BaseViewController.swift
//  machApp
//
//  Created by lukas burns on 2/17/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import HockeySDK

enum AlertStyle {
    case info
    case error
}

class BaseViewController: UIViewController {

    var loadingView: LoadingView = LoadingView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        setNavigationBarStyle()
        self.hideKeyboardWhenTappedOutside()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func setNavigationBarStyle() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.frame = view.bounds
    }

    func hideNavigationBar(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func showNavigationBar(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - LoadingView

    func showLoadingView() {
        loadingView.presentInView(parentView: self.view)
    }

    func hideLoadingView() {
        loadingView.dismissFromSuperview()
    }

    func hideLoadingViewWithAnimations(animationBlock: @escaping () -> Void) {
        loadingView.dismissAnimated(animationBlock: animationBlock)
    }

    // MARK: - ToastView

    func showToastWithText(text: String) {
        ToastManager.sharedInstance.show(withText: text)
    }

    func showToastWithAttributedText(text: NSAttributedString) {
        ToastManager.sharedInstance.show(withAttributeText: text)
    }

    func dismissToast() {
        ToastManager.sharedInstance.close()
    }

    func showErrorMessage(title: String, message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { (_) in
            if let completion = completion {
                completion()
            }
        })
        presentAlertController(alert: alert, animated: true, completion: { () in
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }

    func showAlert(title: String, message: String, onAccepted: @escaping() -> Void, onCancelled: @escaping() -> Void) {
       showAlert(with: title, message: message, okText: "Ok", cancelText: "Cancelar", onAccepted: onAccepted, onCancelled: onCancelled)
    }

    // swiftlint:disable:next function_parameter_count
    func showAlert(with title: String, message: String, okText: String, cancelText: String, onAccepted: @escaping() -> Void, onCancelled: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okText, style: .default) { (_) in
            onAccepted()
            self.setNeedsStatusBarAppearanceUpdate()
        })
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel) { (_) in
            onCancelled()
            self.setNeedsStatusBarAppearanceUpdate()
        })
        presentAlertController(alert: alert, animated: true, completion: nil)
    }

    func isForceTouchAvailable() -> Bool {
        return self.traitCollection.forceTouchCapability == .available
    }

    func hideKeyboardWhenTappedOutside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    func showNoInternetConnectionErrorToast() {
        self.showToastWithText(text: NSLocalizedString("no-internet-connection-message", comment: ""))
    }

    func showGeneralErrorToast() {
        self.showToastWithText(text: NSLocalizedString("unkwnown-error-message", comment: ""))
    }

}

extension BaseViewController: UINavigationControllerDelegate {
    // implement those when the nav exists
}

extension BaseViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIPageViewController {

    func showToastWithText(text: String) {
        ToastManager.sharedInstance.show(withText: text)
    }

    func showToastWithAttributedText(text: NSAttributedString) {
        ToastManager.sharedInstance.show(withAttributeText: text)
    }
}

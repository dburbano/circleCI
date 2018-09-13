//
//  InitialLegalViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

enum TermsAndConditionsStatus {
    case userLoggedIn
    case userUnkown
}

class TermsAndConditionsDetailsViewController: BaseViewController {

    // MARK: - Constants
    let spinner: SpinnerView = SpinnerView()

    // MARK: - Variables
    var presenter: TermsAndConditionsDetailsPresenterProtocol?

    // MARK: - Outlets
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.loadLegalTerms()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setup() {
        spinner.setColor(color: Color.warmGreyTwo)
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.delegate = self
    }

    // MARK: Actions
    
    @IBAction func didTapBack(_ sender: Any) {
        presenter?.navigateBackTapped()
    }

}

extension TermsAndConditionsDetailsViewController: TermsAndConditionsDetailsViewProtocol {

    func loadLegalTerms(htmlString: String) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }

    func navigateBack() {
        self.popVC()
    }

    func showSpinner() {
        spinner.presentInView(parentView: self.webView)
    }

    func hideSpinner() {
        spinner.dismissFromSuperview()
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }

}

extension TermsAndConditionsDetailsViewController: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        showSpinner()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideSpinner()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hideSpinner()
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        case .linkClicked:
            // Open links in Safari
            guard let url = request.url else { return true }

            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // openURL(_:) is deprecated in iOS 10+.
                UIApplication.shared.openURL(url)
            }
            return false
        default:
            // Handle other navigation types...
            return true
        }
    }
}

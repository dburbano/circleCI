//
//  WebViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/8/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class WebViewController: BaseViewController {

    // MARK: Outlets
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var uiWebView: UIWebView!
    @IBOutlet weak var transitionView: UIView!

    // MARK: Constants
    let successFailureSegue = "successFailureSegue"
    let zendeskArticleName = "filter_cashintc"

    // MARK: Variables
    var webUrlResponse: WebPayURLResponse?
    var presenter: WebPresenterProtocol?
    var executeOperationDelegate: ExecuteOperationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let response = webUrlResponse {
            uiWebView.loadRequest(response.urlRequest)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.topContainer.setMachGradient(includesStatusBar: true, navigationBar: nil, withRoundedBottomCorners: true, withShadow: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: Actions
    @IBAction func didPressBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didPressHelp(_ sender: Any) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == successFailureSegue {
            let destinationVC = segue.destination as? FinishCreditCardInscriptionViewController
            destinationVC?.response = sender as? CreditCardSignupResponse
        }
    }
}

extension WebViewController: WebViewProtocol {
    func didSignUpCreditCard(with response: CreditCardResponse) {
        performSegue(withIdentifier: successFailureSegue, sender: CreditCardSignupResponse.success(response: response))
    }

    func couldntSignupCreditCard() {
        performSegue(withIdentifier: successFailureSegue, sender: CreditCardSignupResponse.failure)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }

    func showServerError() {
        super.showGeneralErrorToast()
    }

    func showBlockAction(with message: String) {
        executeOperationDelegate?.actionWasDeniedBySmyte(with: message)
    }
    
    func closeView() {
        navigationController?.popViewController(animated: true)
    }
}

extension WebViewController: UIWebViewDelegate {

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if  webView.request?.url?.absoluteString == webUrlResponse?.responseURL {
            if let response = webUrlResponse {
                presenter?.callEndpoint(with: response.token)
                transitionView.isHidden = false
            }
        }
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if let response = webUrlResponse {
            if webView.request?.url?.absoluteString == response.urlRequest.url?.absoluteString {
                showServerError()
                navigationController?.popViewController(animated: true)
            }
        }
    }
}

//
//  InviteViewController.swift
//  machApp
//
//  Created by Nicolas Palmieri on 6/29/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class InviteViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var topView: UIView!

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        self.popVC()
    }

    @IBAction func shareTapped(_ sender: Any) {
        self.popActivityController()
    }

    // MARK: - Private
    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
    }

    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }

    internal func popActivityController() {
        //swiftlint:disable:next force_unwrapping
        let machUrl: NSURL = NSURL(string: "somosmach.com")!
        //swiftlint:disable:next force_unwrapping
        let firstActivityItem = "Hola! Te invito a usar MACH para que puedas realizar pagos y cobros de la manera más fácil y segura. Regístrate con este enlace: " + machUrl.absoluteString!

        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, machUrl], applicationActivities: nil)

        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]

        self.present(activityViewController, animated: true, completion: nil)
    }
}

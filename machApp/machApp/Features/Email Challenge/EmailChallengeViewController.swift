//
//  EmailChallengeViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class EmailChallengeViewController: BaseViewController {

    //Outlets
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var validatedEmailIcon: UIImageView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var mailErrorLabel: UILabel!
    
    var presenter: EmailChallengePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        presenter?.viewWasLoaded()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
}

extension EmailChallengeViewController: EmailChallengeViewProtocol {
    
    func updateEmail(with text: String) {
        emailLabel.text = text
        validatedEmailIcon.isHidden = false
    }
    
    func setProgressBarSteps(currentStep: Int, totalSteps: Int) {
        self.progressBar?.currentStep = currentStep
        self.progressBar?.totalSteps = totalSteps
    }
    
    func showNoInternetConnectionError() {
        super.showNoInternetConnectionErrorToast()
    }
    
    func showServerError() {
        super.showGeneralErrorToast()
    }
    
    func showClientError(with text: String) {
        super.showToastWithText(text: "Ha ocurrido un error")
    }
    
    func hideActivityIndicator(with flag: Bool) {
        if flag {
            activitySpinner.stopAnimating()
        } else {
            activitySpinner.startAnimating()
        }
    }
    
    func showFetchMailError() {
        mailErrorLabel.isHidden = false
    }
    
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(self)
        self.presenter?.applicationDidBecomeActive()
    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(self)
        self.presenter?.applicationWillEnterForeground()
    }
}

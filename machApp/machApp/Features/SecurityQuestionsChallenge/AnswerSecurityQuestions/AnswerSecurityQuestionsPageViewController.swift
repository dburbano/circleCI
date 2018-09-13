//
//  IdentityRecoveryPageViewController.swift
//  machApp
//
//  Created by lukas burns on 5/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class AnswerSecurityQuestionsPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    // Variables
    let showSecurityQuestionsSuccess: String = "showSecurityQuestionsSuccess"

    var presenter: AnswerSecurityQuestionsPresenterProtocol?
    var currentPage: QuestionViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? QuestionViewController {
            var index = viewController.index
            index -= 1
            return contentViewController(at: index)
        }
        return contentViewController(at: 0)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? QuestionViewController {
            var index = viewController.index
            index += 1
            return contentViewController(at: index)
        }
        return contentViewController(at: 0)
    }

    func contentViewController(at index: Int) -> QuestionViewController? {
        let questionViewModel = self.presenter?.getQuestionViewModel(at: index)
        guard questionViewModel != nil else { return nil }
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier:
            "QuestionViewController") as? QuestionViewController {
            pageContentViewController.index = index
            pageContentViewController.questionViewModel = questionViewModel
            pageContentViewController.numberOfQuestions = self.presenter?.getNumberOfQuestions() ?? 0
            currentPage = pageContentViewController
            return pageContentViewController
        }
        currentPage = nil
        return nil
    }

    func forward(index: Int) {
        if let nextViewController = contentViewController(at: index + 1) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSecurityQuestionsSuccess, let destinationVC = segue.destination as? SecurityQuestionsSuccessViewController, let authenticationResponse = sender as? AuthenticationResponse {
            destinationVC.authenticationResponse = authenticationResponse
            destinationVC.challengeDelegate = self.presenter?.getChallengeDelegate()
        }
    }
}

extension AnswerSecurityQuestionsPageViewController: AnswerSecurityQuestionsViewProtocol {
    func setProgressBarSteps(currentStep: Int, totalSteps: Int) {
        //TODO
    }
    

    func setQuestionViewController(at index: Int) {
        if let startingViewController = contentViewController(at: index) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    func navigateToSecurityQuestionsSuccess(with authenticationResponse: AuthenticationResponse) {
        self.performSegue(withIdentifier: showSecurityQuestionsSuccess, sender: authenticationResponse)
    }

    func showLoadingButton() {
        if let currentPage = currentPage {
            currentPage.disableContinueButton()
        }
    }

    func hideLoadingButton() {
        if let currentPage = currentPage {
            currentPage.enableContinueButton()
        }
    }

    internal func showError(title: String, message: String, onAccepted: (() -> Void)?) {
        self.showErrorMessage(title: "Error", message: message, completion: nil)
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

    func showNoInternetConnectionError() {
        self.showToastWithText(text: NSLocalizedString("no-internet-connection-message", comment: ""))
    }

    func showServerError() {
        self.showToastWithText(text: NSLocalizedString("unkwnown-error-message", comment: ""))
    }

}

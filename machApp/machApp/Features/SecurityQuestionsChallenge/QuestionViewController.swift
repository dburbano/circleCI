//
//  QuestionViewController.swift
//  machApp
//
//  Created by lukas burns on 5/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class QuestionViewController: BaseViewController {

    var index = 0
    var numberOfQuestions = 0
    var questionViewModel: QuestionViewModel?

    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionTitleNumberLabel: UILabel!
    @IBOutlet weak var maximumQuestionNumberLabel: UILabel!
    @IBOutlet weak var continueButton: LoadingButton!
    @IBOutlet weak var providerStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionNumberLabel.text = (index + 1).toString
        self.questionTitleLabel.text = questionViewModel?.text ?? ""
        self.maximumQuestionNumberLabel.text = numberOfQuestions.toString
        self.questionTitleNumberLabel.text = (index + 1).toString
        self.hideNavigationBar(animated: false)
        self.continueButton.setAsInactive()
        if let provider = questionViewModel?.provider {
            switch provider {
            case .equifax:
                providerStackView.isHidden = false
            default:
                providerStackView.isHidden = true
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewWillLayoutSubviews()
        self.setNeedsStatusBarAppearanceUpdate()
    }

    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        if let pageViewController = parent as? AnswerSecurityQuestionsPageViewController {
            pageViewController.forward(index: index)
        }
    }

    // MARK: - Actions
    @IBAction func unwindToQuestion(segue: UIStoryboardSegue) {
        print("Back to Question")
    }

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        _ = UnwindScaleSegue(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? RadioButtonGroupViewController {
            destinationViewController.questionOptions = questionViewModel?.options
            destinationViewController.delegate = self
        }
    }

    func disableContinueButton() {
        self.continueButton.setAsLoading()
    }

    func enableContinueButton() {
        if !self.continueButton.isEnabled {
            self.continueButton.setAsActive()
            self.continueButton.bloatOnce()
        }
    }

}

extension QuestionViewController: RadioButtonGroupDelegate {

    func optionSelected() {
        if !self.continueButton.isEnabled {
            self.enableContinueButton()
        }
    }
}

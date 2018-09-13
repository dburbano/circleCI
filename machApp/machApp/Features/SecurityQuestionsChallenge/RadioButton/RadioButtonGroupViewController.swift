//
//  RadioButtonGroupViewController.swift
//  machApp
//
//  Created by lukas burns on 5/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

protocol RadioButtonGroupDelegate: class {
    func optionSelected()
}

class RadioButtonGroupViewController: UIViewController {

    var questionOptions: [QuestionOptionViewModel]?
    @IBOutlet public var radioButtons: [RadioButton] = [RadioButton]()

    var delegate: RadioButtonGroupDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initializeQuestions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func unselectAllRadioButtons() {
        for radioButton in radioButtons {
            radioButton.unselect()
        }
        if let options = questionOptions {
            for option in options {
                option.isSelected = false
            }
        }
    }

    func initializeQuestions() {
        guard let options = questionOptions else { return }
        for (index, option) in options.enumerated() {
            let radioButton = radioButtons.get(at: index)
            radioButton?.questionLabel.text = option.text
            if option.isSelected {
                radioButton?.select()
            } else {
                radioButton?.unselect()
            }
        }
    }

    @IBAction func questionOptionSelected(_ sender: UITapGestureRecognizer) {
        unselectAllRadioButtons()
        guard let radioButton = sender.view as? RadioButton else { return }
        if let index = radioButtons.index(of: radioButton) {
            questionOptions?.get(at: index)?.isSelected = true
            radioButton.select()
            delegate?.optionSelected()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

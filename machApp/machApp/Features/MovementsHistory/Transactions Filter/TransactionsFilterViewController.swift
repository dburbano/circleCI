//
//  TransactionsFilterViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/4/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

protocol TransactionsFilterDelegate: class {
    func didSelect(filter: TransactionsFilter)
}

class TransactionsFilterViewController: UIViewController {

    @IBOutlet weak var acceptButton: LoadingButton!
    @IBOutlet public var radioButtons: [RadioButton] = [RadioButton]()

    let backToTransactionsSegue = "backToHistorySegue"
    var selectedFilter: TransactionsFilter?
    weak var delegate: TransactionsFilterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFilters()
        acceptButton.setAsActive()
    }

    @IBAction func didTouchScreen(_ sender: Any) {
        performSegue(withIdentifier: backToTransactionsSegue, sender: nil)
    }

    func initializeFilters() {

        for (index, filter) in TransactionsFilter.allValues.enumerated() {
            let radioButton = radioButtons.get(at: index)
            radioButton?.questionLabel.text = filter.rawValue

            if let filter = selectedFilter {
                if index == TransactionsFilter.getIndex(with: filter) {
                    radioButton?.select()
                    selectedFilter = TransactionsFilter.getCase(with: 0)
                } else {
                    radioButton?.unselect()
                }
            }
        }
    }

    func unselectAllRadioButtons() {
        for radioButton in radioButtons {
            radioButton.unselect()
        }
    }

    @IBAction func filterOptionSelected(_ sender: UITapGestureRecognizer) {
        unselectAllRadioButtons()
        guard let radioButton = sender.view as? RadioButton else { return }
        if let index = radioButtons.index(of: radioButton) {
            radioButton.select()
            selectedFilter = TransactionsFilter.getCase(with: index)
        }
    }

    @IBAction func didPressAccept(_ sender: Any) {
        if let filter = selectedFilter {
            delegate?.didSelect(filter: filter)
            performSegue(withIdentifier: backToTransactionsSegue, sender: nil)
        }
    }
}

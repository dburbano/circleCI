//
//  TransactionsViewCell.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/3/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class TransactionsViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var entityInvolvedLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    func initialize(with historyViewModel: HistoryViewModel, evenRow: Bool) {
        dateLabel.text = historyViewModel.date
        switch historyViewModel.transactionFilterType {
        case .paymentReceived, .cashIn:
            typeLabel.textColor = Color.dodgerBlue
        case .paymentSent, .cashout:
            typeLabel.textColor = Color.reddishPink
        case .machCard:
            typeLabel.textColor = Color.violetBlue
        case .other:
            typeLabel.textColor = Color.violetBlue
        }
        
        switch historyViewModel.amount {
        case let amount where amount >= 0:
            amountLabel?.text = historyViewModel.amount.toCurrency()
            amountLabel?.textColor = Color.dodgerBlue
        case let amount where amount < 0:
            let positiveAmount = historyViewModel.amount * -1
            amountLabel?.text = "-\(positiveAmount.toCurrency())"
            amountLabel?.textColor = Color.reddishPink
        default:
            break
        }
        
        switch historyViewModel.transactionOriginalType {
        case .annuled:
            guard let text = amountLabel.text else { break }
            let attString = NSMutableAttributedString(string: text,
                                                      attributes: [NSAttributedStringKey.strikethroughStyle : NSNumber(value: 1)])
            amountLabel.attributedText = attString
        default:
            break
        }
        
        typeLabel.text = historyViewModel.title
        entityInvolvedLabel.text = historyViewModel.description
        backgroundColor = evenRow ? UIColor(gray: 238.0) : .white
    }

}

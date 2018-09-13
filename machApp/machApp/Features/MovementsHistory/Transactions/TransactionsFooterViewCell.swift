//
//  TransactionsFooterViewCell.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 3/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

protocol TransactionsFooterDelegate: class {
    func didPressLoadMore()
}

class TransactionsFooterViewCell: UITableViewCell {

    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var separatorView: UIView!
    
    weak var delegate: TransactionsFooterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadingIndicator.stopAnimating()
        
    }
    
    func initialize(with model: TransactionFooterViewModel?, isEven: Bool) {
        if let model = model {
            let title: String
            
            messageButton.isHidden = false
            switch model.state {
            case .moreTransactionsAvailable:
                title = "Mostrando hasta \(model.stDate). Cargar más"
                messageButton.isEnabled = true
                separatorView.isHidden = !isEven
            case .noMoreTransactionsAvailable:
                title = ""//"Mostrando hasta \(model.stDate)."
                messageButton.isEnabled = false
                separatorView.isHidden = true
            }
            let titleNSString = NSString(string: title)
            let attString =
                NSMutableAttributedString(string: title,
                                          // swiftlint:disable:next force_unwrapping
                                          attributes: [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 12.0)!,
                                                       NSAttributedStringKey.foregroundColor: Color.greyishBrown])
            
            let range = titleNSString.range(of: "Cargar más")
            attString.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.brightSkyBlue, range: range)
            messageButton.setAttributedTitle(attString, for: .normal)
        }
    }

    @IBAction func didPressChargeMore(_ sender: Any) {
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        messageButton.isHidden = true
        delegate?.didPressLoadMore()
    }
    
}

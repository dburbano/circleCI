//
//  NoTransactionsView.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/31/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class NoTransactionsView: UIView {

    @IBOutlet weak var messageLabel: UILabel!

    class func instanceFromNib() -> NoTransactionsView? {
        let view = UINib(nibName: "NoTransactionsView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? NoTransactionsView
        return view
    }

    override func didMoveToSuperview() {
        if let superView = superview {
            leadingAnchor.constraint(equalTo: superView.leadingAnchor)
            trailingAnchor.constraint(equalTo: superView.trailingAnchor)
            topAnchor.constraint(equalTo: superView.topAnchor)
            bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        }
    }

    func setlabel(with message: String) {
        messageLabel.text = message
    }
}

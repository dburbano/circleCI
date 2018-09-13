//
//  UIView+View.swift
//  machApp
//
//  Created by lukas burns on 11/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

extension UIStackView {
    public func pinBackground(backgroundView: UIView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(backgroundView, at: 0)
        backgroundView.pin(to: self)
    }
}

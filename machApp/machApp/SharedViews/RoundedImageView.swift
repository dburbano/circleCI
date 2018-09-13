//
//  RoundedImageView.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImageView: UIImageView {

    override func layoutSubviews() {
        setupView()
    }

    private func setupView() {
        self.clipsToBounds = true
        self.setCornerRadius(radius: self.frame.w/2)
    }
}

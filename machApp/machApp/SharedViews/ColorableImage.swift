//
//  ColorableImage.swift
//  machApp
//
//  Created by lukas burns on 3/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
class ColorableImage: UIImageView {

    @IBInspectable
    public var color: UIColor = UIColor.black {
        didSet {
            setupView()
        }
    }

    override func layoutSubviews() {
        setupView()
    }

    private func setupView() {
        self.image = self.image?.tintImage(color: self.color)
    }
}

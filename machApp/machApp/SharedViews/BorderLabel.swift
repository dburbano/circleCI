//
//  BorderedLabel.swift
//  machApp
//
//  Created by lukas burns on 4/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
class BorderLabel: TabbedLabel {

    @IBInspectable
    public var borderColor: UIColor = UIColor.black {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var borderWidth: CGFloat = 0.0 {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            setupView()
        }
    }

//    override func draw(_ rect: CGRect) {
//         Drawing code
//    }

    func setupView() {
        self.addBorder(width: borderWidth, color: borderColor)
        self.setCornerRadius(radius: cornerRadius)
    }

}

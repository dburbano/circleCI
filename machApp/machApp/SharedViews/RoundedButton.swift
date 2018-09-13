//
//  RoundedButton.swift
//  machApp
//
//  Created by lukas burns on 5/4/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var borderColor: UIColor = UIColor.clear {
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
    public var shadowColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }

    func setupView() {
        self.setCornerRadius(radius: cornerRadius)
        self.addBorder(width: borderWidth, color: borderColor)
        self.layoutSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = false
        if self.state == UIControlState.normal {
            self.addShadow(offset: CGSize(width: 0, height: 3), radius: 2.0, color: shadowColor, opacity: 1.0, cornerRadius: cornerRadius)
        } else {
            self.hideShadow()
        }
    }
    
    func hideShadow() {
        self.layer.shadowOpacity = 0.0
    }
    
    func showShadow() {
        self.layer.shadowOpacity = 1.0
    }

}

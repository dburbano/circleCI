//
//  BorderedView.swift
//  machApp
//
//  Created by lukas burns on 10/23/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedView: UIView {

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
    
    @IBInspectable
    public var shadowOffsetWidth: Int = 0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var shadowOffsetHeight: Int = 3 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var shadowRadius: CGFloat = 2.0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var shadowOpacity: Float = 1.0 {
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
        self.addShadow(
            offset: CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight),
            radius: shadowRadius,
            color: shadowColor,
            opacity: shadowOpacity,
            cornerRadius: cornerRadius
        )
    }

}

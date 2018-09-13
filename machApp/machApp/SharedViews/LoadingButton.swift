//
//  LoadingButton.swift
//  machApp
//
//  Created by lukas burns on 8/30/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LoadingButton: RoundedButton {

    var spinner: SpinnerView = SpinnerView()
    var text: String = ""

    @IBInspectable
    public var inactiveColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var loadingColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var activeColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var spinnerColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }

    override func setupView() {
        super.setupView()
        self.layoutSubviews()
        self.backgroundColor = activeColor
        self.text = self.titleLabel?.text ?? ""
        self.spinner.setColor(color: self.spinnerColor)
        self.showShadow()
    }

    func setAsLoading() {
        self.isEnabled = false
        self.titleLabel?.text = ""
        UIView.animate(withDuration: 0.4) {
            self.titleLabel?.alpha = 0
            self.spinner.setColor(color: UIColor.white)
            self.spinner.presentInView(parentView: self)
            self.backgroundColor = self.loadingColor
        }
    }

    func setAsInactive() {
        self.isEnabled = false
        self.backgroundColor = inactiveColor
        self.hideShadow()
    }

    func setAsActive() {
        self.titleLabel?.text = self.text
        self.isEnabled = true
        self.titleLabel?.alpha = 1
        self.spinner.removeFromSuperview()
        self.backgroundColor = self.activeColor
    }

}

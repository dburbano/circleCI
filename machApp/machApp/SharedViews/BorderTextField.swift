//
//  BorderTextField.swift
//  machApp
//
//  Created by lukas burns on 5/11/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

protocol BorderTextFieldDelegate: class {
    func editingBegun(_ textField: BorderTextField)

    func editingEnded(_ textField: BorderTextField)
}

@IBDesignable
class BorderTextField: UITextField {

    var borderLayer: CALayer?
    weak var classDelegate: BorderTextFieldDelegate?
    var isWithError: Bool = false

    // Initialize
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldIsFocused), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldEndFocus), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: self)
        self.layoutSubviews()
    }

    @IBInspectable
    public var borderWidth: CGFloat = 0.0 {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var unselectedBorderColor: UIColor = UIColor.gray {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var selectedBorderColor: UIColor = UIColor.black {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var errorBorderColor: UIColor = UIColor.red {
        didSet {
            setupView()
        }
    }

    func setupView() {
        self.layoutSubviews()
        changeBorderLayer(color: unselectedBorderColor)
        if let borderLayer = borderLayer {
            if isWithError {
                borderLayer.borderColor = errorBorderColor.cgColor
            } else if isFirstResponder {
                borderLayer.borderColor = selectedBorderColor.cgColor
            }
        }
    }

    @objc func textFieldIsFocused() {
        isWithError = false
        if let borderLayer = borderLayer {
            borderLayer.borderColor = selectedBorderColor.cgColor
        }
        self.classDelegate?.editingBegun(self)
    }

    @objc func textFieldEndFocus() {
        guard isWithError == false else { return }
        if let borderLayer = borderLayer {
            borderLayer.borderColor = unselectedBorderColor.cgColor
        }
        self.classDelegate?.editingEnded(self)
    }

    func showError() {
        isWithError = true
        if let borderLayer = borderLayer {
            borderLayer.borderColor = errorBorderColor.cgColor
        }
    }

    func hideError() {
        isWithError = false
        if let borderLayer = borderLayer {
            borderLayer.borderColor = selectedBorderColor.cgColor
        }
    }

    func changeBorderLayer(color: UIColor) {
        if borderLayer != nil {
            borderLayer?.removeFromSuperlayer()
        }
        self.borderLayer = self.drawBottomBorder(borderWidth: borderWidth, color: color)
    }
}

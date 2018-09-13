//
//  PasscodeButton.swift
//  machApp
//
//  Created by lukas burns on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
public class PasscodeButtonView: UIButton {

    @IBInspectable
    public var passcodeValue: String = "1"

    @IBInspectable
    public var activeTextColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var disabledTextColor: UIColor = UIColor.white.withAlphaComponent(0.5) {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var highlightBackgroundColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    private var defaultBackgroundColor = UIColor.clear

    private func setupView() {
        if let backgroundColor = backgroundColor {
            defaultBackgroundColor = backgroundColor
        }
        self.setTitleColor(activeTextColor, for: .normal)
        self.setTitleColor(disabledTextColor, for: .disabled)
    }
}

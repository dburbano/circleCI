//
//  SignPasscodeButtonView.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class SignPasscodeButtonView: UIButton {

    @IBInspectable
    public var passcodeValue: String = "1"

    @IBInspectable
    public var borderColor: UIColor = UIColor.white {
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
    }
}

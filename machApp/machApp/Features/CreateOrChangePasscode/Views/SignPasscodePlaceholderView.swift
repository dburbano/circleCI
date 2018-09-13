//
//  SignPasscodePlaceholderView.swift
//  machApp
//
//  Created by Nicolas Palmieri on 4/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

@IBDesignable
public class SignPasscodePlaceholderView: UIView {

    public enum State {
        case inactive
        case active
        case error
    }

    @IBInspectable
    public var activeImage: UIImage? = nil {
        didSet {
            setupView()
        }
    }

    @IBInspectable
    public var inactiveImage: UIImage? = nil {
        didSet {
            setupView()
        }
    }

    var dotImageView: UIImageView?
    var grayDotImageView: UIImageView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 10, height: 10)

    }

    private func setupView() {
        layer.cornerRadius = self.w / 2
        guard let letter = self.activeImage else {
            return
        }
        guard let calm = self.inactiveImage else {
            return
        }
        dotImageView = UIImageView(image: letter)
        grayDotImageView = UIImageView(image: calm)
    }

    public func animateState(state: State) {
        switch state {
        case .active:
            // swiftlint:disable:next force_unwrapping
            self.addSubview(self.dotImageView!)
            self.dotImageView?.centerInSuperView()
            self.backgroundColor = UIColor.clear
        case .inactive:
            // swiftlint:disable:next force_unwrapping
            self.addSubview(self.grayDotImageView!)
            self.grayDotImageView?.centerInSuperView()
            self.backgroundColor = UIColor.clear
            self.dotImageView?.removeFromSuperview()
        case .error:
            self.dotImageView?.removeFromSuperview()
        }
    }
}

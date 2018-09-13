//
//  LoadingView.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    private var spinner: UIActivityIndicatorView
    private var loadingLabel: UILabel

    override init(frame: CGRect) {
        loadingLabel = UILabel()
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        loadingLabel = UILabel()
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        super.init(coder: aDecoder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let midX: CGFloat = bounds.midX
        let midY: CGFloat = bounds.midY

        spinner.center = CGPoint(x: midX, y: midY)
        // We make this setup for the label to place it right below the spinner
        loadingLabel.frame = CGRect(x: 0, y: bounds.size.height / 2 + 5.0, width: bounds.size.width, height: 43)
    }

    // MARK: - Public

    func presentInView(parentView: UIView) {
        parentView.addSubview(self)
        frame = parentView.bounds
        alpha = 1.0
    }

    func dismissFromSuperview() {
        super.removeFromSuperview()
    }

    func dismissAnimated(animationBlock: (() -> Void)?) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.alpha = 0.0
            if let animation = animationBlock {
                animation()
            }
            }, completion: { [weak self] _ in
                self?.removeFromSuperview()
        })
    }

    // MARK: - Private

    private func setupView() {
        backgroundColor = UIColor.white

        addSubview(spinner)
        spinner.startAnimating()

        loadingLabel.text = "Hang-on, :]"
        loadingLabel.font = UIFont.body()
        loadingLabel.textColor = Color.dodgerBlue
        loadingLabel.textAlignment = .center
        addSubview(loadingLabel)
    }
}

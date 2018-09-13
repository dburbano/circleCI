//
//  SpinnerView.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/28/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class SpinnerView: UIView {

    private var spinner: UIActivityIndicatorView

    override init(frame: CGRect) {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        super.init(coder: aDecoder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        spinner.center = self.center
    }

    // MARK: - Public 
    func presentInView(parentView: UIView) {
        parentView.addSubview(self)
        frame = parentView.bounds
        alpha = 1.0
    }

    func setColor(color: UIColor) {
        spinner.color = color
    }

    func dismissFromSuperview() {
        super.removeFromSuperview()
    }

    // MARK: - Private
    private func setupView() {
        backgroundColor = UIColor.clear
        addSubview(spinner)
        spinner.startAnimating()
    }
}

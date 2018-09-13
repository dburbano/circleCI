//
//  ToastManager.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/7/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class ToastManager {

    static let sharedInstance: ToastManager = ToastManager()
    let toastView: ToastView = ToastView()
    var isPresenting: Bool = false

    init() {
        // swiftlint:disable:next force_unwrapping
        UIApplication.shared.keyWindow!.addSubview(toastView)
        toastView.configureBehaviors()
    }

    func show(withText text: String) {
        toastView.setMessage(text: text)
        toastView.submit()
    }

    func show(withAttributeText text: NSAttributedString) {
        toastView.setMessage(withFormattedString: text)
        toastView.submit()
    }

    func close() {
        toastView.close()
    }
}

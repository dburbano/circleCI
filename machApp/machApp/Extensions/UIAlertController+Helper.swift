//
//  UIAlertController+Helper.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

extension UIViewController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    private struct AssociatedKeys {
        static var presentedAlert: UIAlertController?
    }

    public var presentedAlert: UIAlertController? {
        get {
            if let alert = objc_getAssociatedObject(self, &AssociatedKeys.presentedAlert) as? UIAlertController {
                return alert
            }
            return nil
        }
        set (newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.presentedAlert, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func presentAlertController(alert: UIAlertController, animated: Bool, completion: (() -> Void)? ) {
        presentedAlert = alert
        present(alert, animated: animated, completion: completion)
    }

    func dismissAlertController() {
        if presentedAlert != nil {
            dismiss(animated: false, completion: nil)
            presentedAlert = nil
        }
    }
}

extension UIAlertController {

    func tapButtonAtIndex(index: Int) {
        let block = self.actions[index].value(forKey: "handler")
        let handler = unsafeBitCast(block, to: AlertHandler.self)

        handler(self.actions[index])
    }
}

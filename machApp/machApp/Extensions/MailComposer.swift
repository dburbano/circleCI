//
//  MailComposer.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/6/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import MessageUI

enum MailComposerErrors: Int {
    case noErrors
    case simulatorIsNotSupported
    case accountIsNeeded
}

class MailComposer: NSObject, MFMailComposeViewControllerDelegate {
    let composer: MFMailComposeViewController = MFMailComposeViewController()

    override init() {
        super.init()
        configureComposer()
    }

    // MARK: - Mail composer delegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private methods

    fileprivate func configureComposer() {
        composer.mailComposeDelegate = self
        composer.navigationBar.tintColor = UIColor.white
    }

    // MARK: - Public methods

    func setSubject(text: String) {
        composer.setSubject(text)
    }

    func setMessageBody(text: String) {
        composer.setMessageBody(text, isHTML: false)
    }

    func setRecipients(recipients: [String]) {
        composer.setToRecipients(recipients)
    }

    func configure() -> MailComposerErrors {
        // In order to make it happen over the simulator, the following magic is needed. Otherwise, it will crash :]
        #if arch(i386) || arch(x86_64)
            return .simulatorIsNotSupported
        #else
            guard MFMailComposeViewController.canSendMail() else { return .accountIsNeeded }

            return .noErrors
        #endif
    }
}

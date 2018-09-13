//
//  InviteContactsViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 12/27/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import ActiveLabel

protocol InviteContactsDelegate: class {
    func didPressInviteContacts()
}

class InviteContactsViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setInviteText()
    }

    weak var delegate: InviteContactsDelegate?

    @IBOutlet weak var inviteInformationLabel: ActiveLabel!

    @IBAction func didPressInviteContacts(_ sender: Any) {
        delegate?.didPressInviteContacts()
    }
    
    private func setInviteText() {
        let customType = ActiveType.custom(pattern: "\\sver premios\\b")
        inviteInformationLabel.enabledTypes = [customType]
        inviteInformationLabel.text = "¿Tienes amigos sin MACH? Gana premios por invitarlos ver premios"
        inviteInformationLabel.customColor[customType] = Color.dodgerBlue
        inviteInformationLabel.customSelectedColor[customType] = Color.violetBlue
        inviteInformationLabel.handleCustomTap(for: customType) { element in
            self.openAwardsURL()
        }
    }

    private func openAwardsURL() {
        guard let url = URL(string: "https://www.somosmach.com/programa-referidos") else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

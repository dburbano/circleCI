//
//  BlockedUserViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 1/25/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit
import ActiveLabel

class BlackListedViewController: UIViewController {

    let zendeskArticleName = "filter_cuentabloqueada"

    @IBOutlet weak var informationLabel: ActiveLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInformationLabel()
        self.navigationController?.navigationBar.isHidden = true
    }

    private func setupInformationLabel() {
        let customType = ActiveType.custom(pattern: "\\sentra aquí\\b")
        informationLabel.enabledTypes = [customType]
        informationLabel.text = "Si quieres saber más o crees que esto fue un error entra aquí"
        informationLabel.customColor[customType] = Color.dodgerBlue
        informationLabel.customSelectedColor[customType] = Color.violetBlue
        informationLabel.handleCustomTap(for: customType) { element in
            self.didPressedContactUs()
        }
    }
    
    private func didPressedContactUs() {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
    }
}

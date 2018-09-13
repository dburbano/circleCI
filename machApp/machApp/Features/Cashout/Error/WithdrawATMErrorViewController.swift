//
//  WithdrawATMErrorViewController.swift
//  machApp
//
//  Created by Santiago Balestero on 8/13/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class WithdrawATMErrorViewController: BaseViewController {
    let zendeskArticleName = "filter_cashoutatm"

    var titleLabelText: String = "Puedes hacer hasta 4 retiros en cajeros cada 7 días"
    var subtitleLabelText: String = "Para más información visita nuestro"
    var buttonIsHidden: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleLabelText
        subtitleLabel.text = subtitleLabelText
        self.helpButton.isHidden = buttonIsHidden
    }
    
    @IBAction func helpZendeskButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
    }
}

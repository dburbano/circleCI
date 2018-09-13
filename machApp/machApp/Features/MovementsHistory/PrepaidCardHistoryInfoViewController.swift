//
//  PrepaidCardHistoryInfoViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 1/6/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class PrepaidCardHistoryInfoViewController: BaseViewController {

    let zendeskArticleName: String = "filter_historial"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func zendeskHelpButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().mach_card, helpTagAccessed: self.zendeskArticleName).track()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

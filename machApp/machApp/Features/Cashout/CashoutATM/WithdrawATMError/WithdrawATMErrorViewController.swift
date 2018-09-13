//
//  WithdrawATMErrorViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 14/5/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class WithdrawATMErrorViewController: BaseViewController {

    let zendeskArticleName: String = "filter_cashoutatm"

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToHelpCenterButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
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

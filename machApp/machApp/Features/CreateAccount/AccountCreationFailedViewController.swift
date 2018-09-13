//
//  AccountCreationFailedViewController.swift
//  machApp
//
//  Created by Lukas Burns on 1/8/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class AccountCreationFailedViewController: BaseViewController {

    let zendeskArticleName = "filter_registro"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func contactUsButtonTapped(_ sender: RoundedButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
    }
}

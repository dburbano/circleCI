//
//  TEFValidationSuccessViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 19/4/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class TEFValidationSuccessViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController as? AuthenticationNavigationController {
            self.dismissVC {
                navigationController.authenticationDelegate?.authenticationSucceeded()
            }
        }
    }

}

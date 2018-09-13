//
//  SecuritySelfieInstructionsViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 20/4/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class SecuritySelfieInstructionsViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTEFValidationInstruction(_ sender: Any) {
        self.popVC()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func goToSelfieVerificationButtonTapped(_ sender: Any) {
        let email = AccountManager.sharedInstance.getUser()?.email ?? ""
        let rut = AccountManager.sharedInstance.getRut() ?? ""
        let url = "https://ayuda.somosmach.com/hc/es/requests/new?ticket_form_id=360000043351&email=\(email)&rut=\(rut)"

        UIApplication.shared.openURL(URL(string: url)!)
    }

}

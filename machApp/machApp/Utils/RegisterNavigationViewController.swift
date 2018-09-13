//
//  RegisterNavigationViewController.swift
//  machApp
//
//  Created by lukas burns on 4/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
#if STAGING
    import HockeySDK
#endif
#if DEBUG || AUTOMATION
    import HockeySDK
#endif

class RegisterNavigationViewController: UINavigationController {

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

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            #if STAGING
                BITHockeyManager.shared().feedbackManager.showFeedbackComposeViewWithGeneratedScreenshot()
            #elseif DEBUG
                BITHockeyManager.shared().feedbackManager.showFeedbackComposeViewWithGeneratedScreenshot()
            #endif
        }
    }

}

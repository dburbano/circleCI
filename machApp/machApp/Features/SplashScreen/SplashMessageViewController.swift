//
//  SplashMessageViewController.swift
//  machApp
//
//  Created by Lukas Burns on 12/7/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

class SplashMessageViewController: UIViewController {
    
    var index = 0
    var message: String = ""

    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.messageLabel.text = message
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

}

//
//  WithdrawCreatedDialogueViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 28/3/2018.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class WithdrawCreatedDialogueViewController: BaseViewController {

    var amount: Int = 0

    @IBOutlet weak var amountText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.amountText.text = "Ya tienes un retiro creado por \(self.amount.toCurrency())"
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

}

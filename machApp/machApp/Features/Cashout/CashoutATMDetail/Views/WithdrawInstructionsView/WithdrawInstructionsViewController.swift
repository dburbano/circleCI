//
//  WithdrawInstructionsViewController.swift
//  machApp
//
//  Created by Rodrigo Russell on 1/8/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class WithdrawInstructionsViewController: BaseViewController {
    
    let cellIdentifier = "StepCell"
    let titles = ["Paso 1", "Paso 2", "Paso 3", "Paso 4", "Paso 5"]
    let descriptions = [
        "Selecciona un monto a retirar para crear tu código de retiro. Puedes realizar 4 retiros por semana.",
        "Ingresa a la sección MACH dentro del cajero Bci.",
        "Presiona en la opción de Redgiro.",
        "Ingresa el identificador de giro de 12 dígitos.",
        "Ingresa la clave de Redgiro de 5 dígitos para confirmar el retiro."
    ]
    let descriptionImages = [
        "imgATMStep1",
        "imgATMStep2",
        "imgATMStep3",
        "imgATMStep4",
        "imgATMStep5"
    ]
    let zendeskArticleName = "filter_cashoutatm"
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.setMachGradient()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "WithdrawInstructionsTableViewCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func helpZendeskButtonTapped(_ sender: UIButton) {
        ZendeskManager.sharedInstance.openArticle(in: self, articleTags: [self.zendeskArticleName])
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().helpbox, helpTagAccessed: self.zendeskArticleName).track()
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

extension WithdrawInstructionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! WithdrawInstructionsTableViewCell
        
        cell.titleLabel.text = titles[indexPath.row]
        cell.descriptionLabel.text = descriptions[indexPath.row]
        cell.descriptionImage.image = UIImage(named: descriptionImages[indexPath.row])

        return cell
    }
}

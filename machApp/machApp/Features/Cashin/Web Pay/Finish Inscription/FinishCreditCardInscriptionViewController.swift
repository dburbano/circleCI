//
//  FinishCreditCardInscriptionViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 11/9/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit

//swiftlint:disable type_name
class FinishCreditCardInscriptionViewController: UIViewController {

    // MARK: Constants
    let backToAddCreditCardSegue = "backToAddCreditCardSegue"
    let rechargeSegue = "rechargeSegue"

    // MARK: Variables
    var response: CreditCardSignupResponse?

    // MARK: Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var finishButton: LoadingButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    private func setup() {
        finishButton.setAsActive()
        if let response = response {
            switch response {
            case .success:
                logoImage.image = #imageLiteral(resourceName: "ilustracionTarjetaExito")
                titleLabel.text = "¡Listo!"
                subtitleLabel.text = "Tu tarjeta fue agregada con éxito"
            case .failure:
                logoImage.image = #imageLiteral(resourceName: "ilustracionTarjetaError")
                titleLabel.text = "Lo sentimos"
                subtitleLabel.text = "No pudimos comprobar la información de tu tarjeta"
                finishButton.setTitle("Volver", for: .normal)
            }
        }
    }

    // MARK: Actions
    @IBAction func didPressButton(_ sender: Any) {
        if let response = response {
            switch response {
            case .success:
                performSegue(withIdentifier: rechargeSegue, sender: response)
            case .failure:
                performSegue(withIdentifier: backToAddCreditCardSegue, sender: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == rechargeSegue {
            let destinationVC = segue.destination as? RechargeViewController
            if let sender = sender as? CreditCardSignupResponse {
                destinationVC?.creditCard = sender.get() as? CreditCardResponse
            }
        }
    }
}

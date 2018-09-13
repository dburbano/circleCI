//
//  PrepaidCardNavigationViewController.swift
//  machApp
//
//  Created by Lukas Burns on 4/13/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit

class PrepaidCardNavigationViewController: UINavigationController {
    
    let showGeneratingPrepaidCard: String = "showGeneratingPrepaidCard"
    let showPrepaidCard: String = "showPrepaidCard"
    let showGeneratePrepaidCard: String = "showGeneratePrepaidCard"
    let showRemovingPrepaidCard: String = "showRemovingPrepaidCard"
    
    var prepaidCards: [PrepaidCard] = [] {
        didSet{
            self.setup()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        if let firstCard = prepaidCards.first {
            // User has a credit card, for now only one is allowed.
            guard let cardState = firstCard.getState else { return }
            switch cardState {
            case .active:
                self.navigateToPrepaidCard(with: firstCard)
            case .pending:
                self.navigateToGeneratingPrepaidCard()
            case .deleting:
                self.navigateToRemovingPrepaidCard()
            }
        } else {
            // User doesn't have a credit card, he hasn't asked for one but is able to generate.
             self.navigateToGeneratePrepaidCard()
        }
    }
    
    func navigateToPrepaidCard(with card: PrepaidCard) {
        print("Navigating from prepaidCardNavigationController")
        self.performSegue(withIdentifier: self.showPrepaidCard, sender: card)
    }
    
    func navigateToGeneratingPrepaidCard() {
        self.performSegue(withIdentifier: self.showGeneratingPrepaidCard, sender: nil)
    }
    
    func navigateToGeneratePrepaidCard() {
        self.performSegue(withIdentifier: self.showGeneratePrepaidCard, sender: nil)
    }

    func navigateToRemovingPrepaidCard() {
        self.performSegue(withIdentifier: self.showRemovingPrepaidCard, sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showGeneratingPrepaidCard, let destinationVC = segue.destination as? SecurityProcessViewController {
            destinationVC.securityRequestType = .prepaidCard
        } else if segue.identifier == self.showPrepaidCard, let destinationVC = segue.destination as? PrepaidCardViewController, let prepaidCard = sender as? PrepaidCard {
            destinationVC.prepaidCard = prepaidCard
        } else if segue.identifier == self.showRemovingPrepaidCard, let destinationVC = segue.destination as? SecurityProcessViewController {
            destinationVC.securityRequestType = .removePrepaidCard
        }
    }

}

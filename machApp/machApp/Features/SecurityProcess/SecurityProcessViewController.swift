//
//  SecurityProcessViewController.swift
//  machApp
//
//  Created by Lukas Burns on 4/10/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import UIKit
import Lottie

protocol SecurityProcessDelegate: class {
    func successfullyFinished(with object: Any?)
}

enum SecurityRequestType {
    case prepaidCard
    case removePrepaidCard
}

class SecurityProcessViewController: UIViewController {
    
    lazy var animationView = LOTAnimationView(name: "processAnimation")
    
    // MARK: - Variables
    var presenter: SecurityProcessPresenterProtocol?
    var securityRequestType: SecurityRequestType?
    
    weak var delegate: SecurityProcessDelegate?

    @IBOutlet weak var processNameLabel: BorderLabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var goHomeButton: RoundedButton!
    @IBOutlet weak var animationContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        self.addAnimationView()
        guard let processType = self.securityRequestType else { return }
        self.presenter?.initializeProcess(processType, with: self.delegate)
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setup() {
        if let securityRequestType = self.securityRequestType {
            switch securityRequestType {
            case .prepaidCard:
                self.processNameLabel?.text = "Generación de tarjeta"
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(prepaidCardCreated(notification:)),
                    name: .PrepaidCardCreated,
                    object: nil
                )
            case .removePrepaidCard:
                self.processNameLabel?.text = "Eliminando tarjeta MACH"
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(prepaidCardRemoved(notification:)),
                    name: .PrepaidCardRemoved,
                    object: nil
                )
            }
        }
    }
    
    private func addAnimationView() {
        animationView.loopAnimation = true
        self.animationContainer?.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        guard let animationContainer = self.animationContainer else { return }
        animationView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: (animationContainer.centerYAnchor)).isActive = true
        animationView.widthAnchor.constraint(equalTo: (animationContainer.widthAnchor)).isActive = true
        animationView.heightAnchor.constraint(equalTo: animationContainer.heightAnchor).isActive = true
        animationView.play()
    }

    @objc private func prepaidCardCreated(notification: Notification) {
        if let userInfo = notification.userInfo, let prepaidCard = userInfo["prepaidCard"] as? PrepaidCard {
            delegate?.successfullyFinished(with: prepaidCard)
        }
    }

    @objc private func prepaidCardRemoved(notification: Notification) {
        delegate?.successfullyFinished(with: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
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

}

extension SecurityProcessViewController: SecurityProcessViewProtocol {
    func showNoInternetConnectionError() {
        
    }
    
    func showServerError() {
        
    }
    
}

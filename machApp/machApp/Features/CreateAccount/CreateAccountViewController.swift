//
//  CreateAccountViewController.swift
//  machApp
//
//  Created by Lukas Burns on 5/25/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class CreateAccountViewController: BaseViewController {
    
    // MARK: - Constants
    let showGeneratePINNumber: String = "showGeneratePINNumber"
    
    // MARK: - Variables
    var presenter: CreateAccountPresenterProtocol?
    lazy var animationView = LOTAnimationView(name: "processAnimation")

    @IBOutlet weak var animationContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addAnimationView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.presenter?.createAccount()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    

    //  MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showGeneratePINNumber, let destinationVC = segue.destination as? GeneratePINNumberViewController {
            destinationVC.accountMode = AccountMode.create
            destinationVC.generatePinMode = GeneratePinMode.create
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
    
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(self)
        self.presenter?.applicationDidBecomeActive()
    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(self)
        self.presenter?.applicationWillEnterForeground()
    }
    
}

extension CreateAccountViewController: CreateAccountViewProtocol {
    
    func navigateToGeneratePINNumber() {
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: self.showGeneratePINNumber, sender: nil)
    }

    func showNoInternetConnectionError() {
        
    }

    func showServerError() {
        
    }
}

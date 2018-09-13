//
//  MoreTableViewController.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 9/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import UIKit
import LocalAuthentication

class MoreTableViewController: UITableViewController {

    // MARK: - Constants
    let zendeskArticleName = ""
    fileprivate let headerIdentifier: String = "header"
    fileprivate let showWithdrawMenu: String = "showWithdrawMenu"
    fileprivate let showInvite: String = "showInvite"
    fileprivate let showHelp: String = "showHelp"
    fileprivate let showLegal: String = "showLegal"
    fileprivate let showChangePin: String = "showChangePin"
    fileprivate let showHistory: String = "showHistory"

    @IBOutlet weak var touchIdSwitchBtn: UISwitch!
    
    var presenter: MoreTablePresenterProtocol!
    var shouldPresentShare: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MoreHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: headerIdentifier)
        self.touchIdSwitchBtn.setOn(presenter?.getUseTouchId() ?? false, animated: false)
        self.touchIdSwitchBtn.isEnabled = self.canUseTouchId() ? true : false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let share = shouldPresentShare, share {
            presenter.presentShare()
            shouldPresentShare = nil
        }
    }

    @IBAction func touchIdSwitchBtn(_ sender: UISwitch) {
        presenter?.setUseTouchId(isOn: touchIdSwitchBtn.isOn)
    }

    private func canUseTouchId() -> Bool {
        let context = LAContext()
        var error: NSError?

        return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as? MoreHeaderView
        guard let section = MoreSections(rawValue: section) else { return nil }
        var sectionText: String
        switch section {
        case .machAccount:
            sectionText = "Cuenta MACH"
        case .settings:
            sectionText = "Configuración"
        case .help:
            sectionText = "Ayuda"
        }
        sectionView?.label.text = sectionText
        //swiftlint:disable:next force_unwrapping
        return sectionView!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.handleDidSelectRowAt(indexPath: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        if identifier == self.showChangePin, let vc = segue.destination as? GeneratePINNumberViewController {
            vc.generatePinMode = GeneratePinMode.change
        }
    }
}

extension MoreTableViewController: MoreTableViewProtocol {

    internal func navigateToHistory() {
        performSegue(withIdentifier: showHistory, sender: nil)
        presenter.trackNavigateToHistory()
    }

    internal func navigateToCashOut() {
        performSegue(withIdentifier: showWithdrawMenu, sender: self)
    }

    internal func inviteFriends(withString string: String, url: URL, excludedTypes: [UIActivityType]) {
        let activityViewController: UIActivityViewController = UIActivityViewController(
            activityItems: [string, url],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = excludedTypes

        self.present(activityViewController, animated: true, completion: nil)
    }

    internal func navigateToChangePIN() {
        performSegue(withIdentifier: showChangePin, sender: self)
    }

    internal func navigateToHelp() {
        SegmentAnalytics.Event.helpCenterAccessed(location: SegmentAnalytics.EventParameter.LocationType().settings, helpTagAccessed: "").track()
        ZendeskManager.sharedInstance.openHelpCenter(in: self)
    }

    internal func navigateToLegal() {
        performSegue(withIdentifier: showLegal, sender: self)
    }

    internal func presentPasscode(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        guard let passcodeViewController = UIStoryboard(name: "Passcode", bundle: nil).instantiateViewController(withIdentifier: "PasscodeViewController") as? PasscodeViewController else {
            return
        }
        passcodeViewController.successCallback = onSuccess
        passcodeViewController.failureCallback = onFailure
        passcodeViewController.setPasscode(passcodeMode: .transactionMode, title: "Ingresa tu PIN para continuar", optionText: "Cancelar")
        let navController = UINavigationController(rootViewController: passcodeViewController)
        navController.navigationBar.isHidden = true
        self.presentVC(navController)
    }

}

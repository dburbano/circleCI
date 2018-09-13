//
//  MoreTablePresenter.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 9/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit
import Branch

enum MoreSections: Int {

    case machAccount = 0
    case settings = 1
    case help = 2

    enum MachAccount: Int {
        case withdraw = 0
        case history = 1
        case invite = 2
    }

    enum Settings: Int {
        case changePin = 0
    }

    enum Help: Int {
        case contactUs = 0
        case termsAndConditions = 1
    }
}

class MoreTablePresenter: MoreTablePresenterProtocol {
    
    weak var view: MoreTableViewProtocol?
    var repository: MoreTableRepositoryProtocol?

    //Customized link
    private let branchUniversalObject: BranchUniversalObject = BranchUniversalObject()
    private let linkProperties: BranchLinkProperties = BranchLinkProperties()
    private var branchGeneratedLink: String?

    init(repository: MoreTableRepositoryProtocol?) {
        self.repository = repository
        self.branchGeneratedLink = BranchIOManager.sharedInstance.getUrl()
    }
    
    // MARK: - MoreTablePresenterProtocol
    func presentShare() {
        let tuple = createInviteActivity()
        SegmentAnalytics.Event.invitationSent(
            location: SegmentAnalytics.EventParameter.InvitationType().invite_menu,
            contact_phone: nil,
            contact_name: nil
            ).track()
        view?.inviteFriends(withString: "", url: tuple.0, excludedTypes: tuple.1)
    }
    
    func handleDidSelectRowAt(indexPath: IndexPath) {

        guard let section = MoreSections(rawValue: indexPath.section) else { return }
        switch section {
        case .machAccount:
            handleMachAccountSectionTap(at: indexPath.row)
        case .settings:
            handleSettingsSectionTap(at: indexPath.row)
        case .help:
            handleHelpSectionTap(at: indexPath.row)
        }
    }

    // MARK: - Private methods
    private func handleMachAccountSectionTap(at row: Int) {
        guard let row = MoreSections.MachAccount(rawValue: row) else { return }
        switch row {
        case .withdraw:
            view?.navigateToCashOut()
        case .invite:
           presentShare()
        case .history:
            view?.navigateToHistory()
        }
    }

    private func handleSettingsSectionTap(at row: Int) {
        guard let row = MoreSections.Settings(rawValue: row) else { return }
        switch row {
        case .changePin:
            self.view?.presentPasscode(onSuccess: passcodeSucceeded, onFailure: passcodeFailed)
        }
    }

    private func passcodeSucceeded() {
        view?.navigateToChangePIN()
    }

    private func passcodeFailed() {}

    private func handleHelpSectionTap(at row: Int) {
        guard let row = MoreSections.Help(rawValue: row) else { return }
        switch row {
        case .contactUs:
            view?.navigateToHelp()
        case .termsAndConditions:
            view?.navigateToLegal()
        }
    }

    private func createInviteActivity() -> (URL, [UIActivityType]) {
        //swiftlint:disable:next force_unwrapping
        let machUrl: URL = URL(string: self.branchGeneratedLink!)!
        let excludedTypes: [UIActivityType] = [.postToWeibo, .print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop]
        return (machUrl, excludedTypes)
    }

    func setUseTouchId(isOn: Bool) {
        repository?.setUseTouchId(isOn: isOn)
        SegmentAnalytics.Event.fingerPrintAuth(enable: isOn).track()
    }

    func getUseTouchId() -> Bool {
        return repository?.getUseTouchId() ?? false
    }
    
    func trackNavigateToHistory() {
        SegmentAnalytics.Event.historyAccessed(location: SegmentAnalytics.EventParameter.LocationType().settings).track()
    }

}

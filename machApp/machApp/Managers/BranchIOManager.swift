//
//  BranchIOManager.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 9/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Branch

class BranchIOManager {

    static let sharedInstance = BranchIOManager()
    private let machDeepviewReferral: String = "mach_deepview_referral"

    var shortUrl: String?

    func setIdentityWith(id: String) {
        Branch.getInstance().setIdentity(id)
    }

    func setRequest(metadataKey: String, value: NSObject) {
        Branch.getInstance().setRequestMetadataKey(metadataKey, value: value)
    }

    func userCompletedActionWith(campaignEvent: CampaignEvent) {
        Branch.getInstance().userCompletedAction(campaignEvent.rawValue)
    }

    private func createShortUrl() {
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject()
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        branchUniversalObject.canonicalUrl = Constants.BranchIO.ShareLink.universalCanonicalUrl
        branchUniversalObject.title = Constants.BranchIO.ShareLink.universalObjectTitle
        linkProperties.channel = Constants.BranchIO.ShareLink.linkPropertiesChannel
        linkProperties.campaign = Constants.BranchIO.ShareLink.linkPropertiesCampaign
        linkProperties.feature = Constants.BranchIO.ShareLink.linkPropertiesInviteFeature
        if let user = AccountManager.sharedInstance.getUser() {
            let userViewModel = UserViewModel(user: user)
            branchUniversalObject.contentDescription = "\(userViewModel.machFirstName) te invita a bajar MACH. La cuenta digital para cobrar y pagar a tus amigos y comprar en comercios internacionales online"
            linkProperties.addControlParam("firstName", withValue: userViewModel.machFirstName)
            linkProperties.addControlParam("lastName", withValue: userViewModel.machLastName)
            linkProperties.addControlParam("machID", withValue: userViewModel.machId)
            linkProperties.addControlParam("email", withValue: userViewModel.email)
            linkProperties.addControlParam("phoneNumber", withValue: userViewModel.phone)
            linkProperties.addControlParam("$android_deepview", withValue: self.machDeepviewReferral)
            linkProperties.addControlParam("$desktop_deepview", withValue: self.machDeepviewReferral)
            linkProperties.addControlParam("$ios_deepview", withValue: self.machDeepviewReferral)
        }
        branchUniversalObject.getShortUrl(with: linkProperties) {[weak self] (url, error) in
            if error == nil {
                self?.shortUrl = url
            }
        }
    }

    func getUrl() -> String {
        self.createShortUrl()
        return self.shortUrl ?? "https://mach.app.link/wbk4xaqF2F"
    }
}

enum CampaignEvent: String {
    case createAccount = "Completar registro"
    case recoverAccount = "Recuperar cuenta"
    case createPayment = "Realizar pago"
    case createRequest = "Realizar cobro"
    case cashoutCompleted = "Realizar cashout"
}

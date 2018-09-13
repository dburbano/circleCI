//
//  SegmentManager.swift
//  machApp
//
//  Created by lukas burns on 11/13/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Analytics

//swiftlint:disable identifier_name
struct SegmentAnalytics {

    enum Trait: String {
        case firstName
        case lastName
        case phone
        case email
        case document_number
    }

    enum EventParameter {
        struct LocationType {
            let registration = "registration"
            let recovery = "recovery"
            let profile_menu = "profile_menu"
            let settings = "settings"
            let navbar = "navbar"
            let home = "home"
            let helpbox = "helpbox"
            let mach_card = "mach_card"
        }
        struct PhoneMethod {
            let text = "text"
            let phone = "phone"
            let bluetooth = "bluetooth"
            let qrCode = "qrCode"
            let link = "link"
            let contact = "contact"
            let push = "push"
        }
        struct IDVerificationMethod {
            let manual = "manual"
            let photo = "photo"
        }
        struct InvitationType {
            let payment = "payment"
            let request = "request"
            let invite_menu = "invite_menu"
            let contact_menu = "contact_menu"
        }
        struct CashInSource {
            let webpayOnClick = "webpayOnClick"
            let ownTransfer = "ownTransfer"
            let webpayPlus = "webpayPlus"
            let externalTransfe = "externalTransfe"
        }
    }

//    enum EventParameter {
//        enum LocationType: String {
//            case registration
//            case recovery
//            case profile_menu
//            case setting_menu
//        }
//        enum PhoneMethod: String {
//            case text
//            case phone
//        }
//        enum InvitationType: String {
//            case payment
//            case request
//            case invite_menu
//            case contact_menu
//        }
//        enum CashInSource: String {
//            case webpayOnClick
//            case ownTransfer
//            case webpayPlus
//            case externalTransfe
//        }
//    }

    enum Event {
        // Activation
        case registrationStarted
        case termsAccepted
        case profileUpdated(email: String, firstName: String, lastName: String, location: String)
        case phoneValidated(location: String, phone: String)
        case idValidated(location: String, method: String, document_number: String)
        case idFailed(reason: String, document_number: String)
        case pinCreated
        case registrationFinished
        case invitationSent(location: String, contact_phone: String?, contact_name: String?)
        case paymentSent(amount: Int, message: String)
        case requestSent(amount: Int, message: String, contactNumber: String)
        case requestCanceled(amount: Int, conctactNumber: String)
        case requestRejected(amount: Int, contactNumber: String)
        case cashInDone(amount: Int, source: String)
        case contactListPermissionAccepted
        case pushNotificationPermissionAccepted
        case pictureUpdated
        case historyAccessed(location: String)
        case helpCenterAccessed(location: String, helpTagAccessed: String)
        case cashInAccessed(location: String)
        case chatgroupAccessed(machId: String, contactName: String, groupId: String)
        case cashOutMenuAccessed(location: String)
        case fingerPrintAuth(enable: Bool)
        case paymentFlowStarted(location: String, method: String)
        case requestFlowStarted(location: String, method: String)
        
        // Retention
        case accountRecoveryStarted
        case accountRecoveryFinished
        case supportContacted
        
        // swiftlint:disable:next cyclomatic_complexity
        func track() {
            switch self {
            case .registrationStarted:
                SegmentManager.sharedInstance.trackEvent(event: "Registration Started", params: [:])
            case .termsAccepted:
                SegmentManager.sharedInstance.trackEvent(event: "Terms Accepted", params: [:])
            case .profileUpdated(let email, let firstName, let lastName, let location):
                SegmentManager.sharedInstance.trackEvent(
                    event: "Profile Updated",
                    params: ["email": email, "firstName": firstName, "lastName": lastName, "location": location]
                )
            case .idValidated(let location, let method, let document_number):
                SegmentManager.sharedInstance.trackEvent(
                    event: "ID Document Validated",
                    params: ["location": location, "method": method, "document_number": document_number]
                )
            case .idFailed(let reason, let document_number):
                SegmentManager.sharedInstance.trackEvent(
                    event: "ID Document Failed",
                    params: ["reason": reason, "document_number": document_number]
                )
            case .phoneValidated(let location, let phone):
                SegmentManager.sharedInstance.trackEvent(event: "Phone Validated", params: ["location": location, "phone": "+\(phone)"])
            case .pinCreated:
                SegmentManager.sharedInstance.trackEvent(event: "PIN Created", params: [:])
            case .registrationFinished:
                SegmentManager.sharedInstance.trackEvent(event: "Registration Finished", params: [:])
            case .invitationSent(let location, let contact_phone, let contact_name):
                SegmentManager.sharedInstance.trackEvent(
                    event: "Invitation Sent",
                    params: ["location": location, "contact_phone": contact_phone ?? "", "contact_name": contact_name ?? ""]
                )
            case .paymentSent(_, _): // amount, message
                break
            case .requestSent(_, _, _): // amount, message, contactNumber
                break
            case .requestCanceled(_, _): // amount, contactNumber
                break
            case .requestRejected(_, _): // amount, contactNumber
                break
            case .cashInDone(_, _): // amount, source
                break
            case .contactListPermissionAccepted:
                break
            case .pushNotificationPermissionAccepted:
                break
            case .pictureUpdated:
                break
            case .accountRecoveryStarted:
                SegmentManager.sharedInstance.trackEvent(event: "Account Recovery Started", params: [:])
            case .accountRecoveryFinished:
                break
            case .supportContacted:
                break
            case .historyAccessed(let location):
                SegmentManager.sharedInstance.trackEvent(event: "Movement History Accessed", params: ["location": location])
            case .helpCenterAccessed(let location, let helpTagAccessed):
                SegmentManager.sharedInstance.trackEvent(event: "Help Center Accessed", params: ["location": location, "helpTagAccessed": helpTagAccessed])
            case .cashInAccessed(let location):
                SegmentManager.sharedInstance.trackEvent(event: "Cash In Menu Accessed", params: ["location": location])
            case .chatgroupAccessed(let machId, let contactName, let groupId):
                SegmentManager.sharedInstance.trackEvent(event: "Chatgroup Accessed", params: ["mach_id": machId, "contact_name": contactName, "group_id": groupId])
            case .cashOutMenuAccessed(let location):
                SegmentManager.sharedInstance.trackEvent(event: "Cash Out Menu Accessed", params: ["location": location])
            case .fingerPrintAuth:
                SegmentManager.sharedInstance.trackEvent(event: "Fingerprint Auth Enabled", params: nil)
            case .paymentFlowStarted(let location, let method):
                SegmentManager.sharedInstance.trackEvent(event: "Payment Flow Started", params: ["location": location, "method": method])
            case .requestFlowStarted(let location, let method):
                SegmentManager.sharedInstance.trackEvent(event: "Request Flow Started", params: ["location": location, "method": method])
            }
        }
    }
}

class SegmentManager {

    static let sharedInstance = SegmentManager()

    private init() {
        let segmentKey = self.getSegmentKey()
        let configuration = SEGAnalyticsConfiguration(writeKey: segmentKey)
        configuration.trackApplicationLifecycleEvents = true
        SEGAnalytics.setup(with: configuration)
    }

    func start() {
    }

    func identifyUser() {
        if let user = AccountManager.sharedInstance.getUser(), let machId = user.machId {
            let phone = user.phone ?? ""
            SEGAnalytics.shared().alias(machId)
            SEGAnalytics.shared().identify(machId, traits: [
                SegmentAnalytics.Trait.firstName.rawValue: user.firstName ?? "",
                SegmentAnalytics.Trait.lastName.rawValue: user.lastName ?? "",
                SegmentAnalytics.Trait.phone.rawValue: "+\(phone)",
                SegmentAnalytics.Trait.email.rawValue: user.email ?? "",
                "avatar": user.images?.small ?? ""
            ])
        }
    }

    func identifyAnonymousUser(firstName: String?, lastName: String?, email: String?, phone: String?, rut: String?) {
        let phoneNumber = phone ?? ""
        SEGAnalytics.shared().identify(
            nil,
            traits: [
                SegmentAnalytics.Trait.firstName.rawValue: firstName ?? "",
                SegmentAnalytics.Trait.lastName.rawValue: lastName ?? "",
                SegmentAnalytics.Trait.phone.rawValue: "+\(phoneNumber)",
                SegmentAnalytics.Trait.email.rawValue: email ?? "",
                SegmentAnalytics.Trait.document_number.rawValue: rut ?? ""
            ]
        )
    }

    func identifyAnonymousUser(traits: [String: String]) {
        SEGAnalytics.shared().identify(nil, traits: traits)
    }

    func setAlias() {
//        guard let machID = AccountManager.sharedInstance.getMachId() else { return }
//        SEGAnalytics.shared().alias(machID)
    }

    func clearUserInformation() {
        SEGAnalytics.shared().reset()
    }

    func trackEvent(event: String, params: [String: Any]?) {
        SEGAnalytics.shared().track(event, properties: params)
    }

    private func getSegmentKey() -> String {
        #if DEBUG || AUTOMATION
            return "Jj5yz4OwVajVF0TYs9BzTAnJKstXxloI"
        #elseif STAGING
            return "Jj5yz4OwVajVF0TYs9BzTAnJKstXxloI"
        #else
            return "DqC8nhbdZk42Zd0lE4mJfr3csT08LdYe"
        #endif
    }
}

//
//  File.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 7/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

// swiftlint:disable nesting
struct Constants {

    struct Legal {
        static let termsURL = "http://static.soymach.com/terminos-condiciones.html"
    }

    struct MachAction {
        static let command = "command"
        static let params = "params"
    }

    struct MachParameter {
        static let key = "key"
        static let value = "value"
    }

    struct URL {
        static let contactUs = "https://ayuda.somosmach.com/hc/es/requests/new"
    }

    struct ApiError {

        static let internalServerError = "internal_server_error"

        struct PhoneVerification {
            static let notMatchingPhoneError = "api_phone_verification_not_matching_phone_error"
            static let phoneNumberAlreadyTakenError = "api_phone_verification_phone_already_used_error"
        }

        struct Cashin {
            static let userVerifitacionNeeded = "api_account_get_information_user_verification_needed"
        }

        struct Cashout {
            static let apiCashoutError = "api_cashout_error"
            static let createMovementCashoutError = "movements_create_cashout_error"
            static let cashoutNotFoundError = "movements_cashout_not_found_error"
            static let processorCashoutError = "processor_cashout_error"
            static let processorAuthorizationDenied = "processor_authorization_denied"
        }

        struct CashoutATM {
            static let getNotFoundError = "cash_last_cash_out_atm_not_found_error"
            static let maxAttemptsError = "cash_cash_out_atm_issued_limit_reached_error"
            static let userVerifitacionNeeded = "cash_cash_out_atm_user_verification_needed"
            static let atmDailyAmountLimit = "cash_cash_out_atm_daily_amount_limit_reached_error"
        }

        struct Payment {
            static let processorInsufficientBalance = "processor_insufficient_balance"
        }

        struct Request {

        }

        struct Transaction {
            static let processorTimeOutError = "processor_timeout_error"
            static let ccaTimeOutError = "cca_network_timeout_error"
            static let invalidSecurityHash = "processor_invalid_security_hash"
        }
        
        struct CheckMail {
            static let authChallengeNotCompleted = "authentication_email_not_yet_verified"
        }

    }

    struct Passcode {
        static let correctPasscodeEntered = "correct_passcode_entered"
    }

    struct WebPay {
        struct AddCreditCard {
            static let url: String = "urlWebpay"
            static let token: String = "token"
            static let responseURL: String = "responseURL"

        }

        struct CreditCardResponse {
            static let id: String = "id"
            static let creditCardType: String = "creditCardType"
            static let last4CardDigits: String = "last4CardDigits"
        }
    }

    struct ExecuteTransaction {
        static let paymentLoadingMessages: [String] = [
            "Conectandose a la Matrix",
            "Escaneando billetes",
            "Liberando paloma mensajera",
            "Pasito a pasito",
            "Contando monedas de $1",
            "Las cosas buenas toman tiempo",
            "La paciencia es la madre de las ciencias",
            "Moviendo el ábaco",
            "Timbrando transacción",
            "Apurando el hamster",
            "Echándole carbón al servidor",
            "Ya viene!... Ya viene!",
            "Chicoteando los caracoles",
            "Reiniciando el router",
            "Lento pero seguro",
            "Buscando a Nemo",
            "Corcheteando comprobantes"
        ]
    }

    struct AnimationConstants {
        struct HomeViewController {
            static let balanceAnimationDelay = 3.0
            static let balanceAnimationDuration = 0.7
        }
    }

    struct BranchIO {
        struct ShareLink {
            static let universalObjectTitle = "MACH: Paga a tus amigos y pide tu tarjeta MACH"
            static let universalObjectContentDescription = "MACH es la primera cuenta digital en Chile que te permite transferir y cobrar entre amigos"
            static let universalCanonicalUrl = "https://www.somosmach.com"
            static let linkPropertiesChannel = "App"
            static let linkPropertiesCampaign = "Referral"
            static let linkPropertiesInviteFeature = "Invite"
        }
    }

    struct DeeplinkParserConstants {
        static let openHost = "open"
        static let groupsComponent = "groups"
        static let movementsCopmponent = "movements"
    }

    struct PushNotificationsConstants {
        struct PushStructure {
            static let data = "payload"
            static let deeplinkData = "deeplink"
        }
    }

}

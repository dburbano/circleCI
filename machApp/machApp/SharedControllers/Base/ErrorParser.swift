//
//  ErrorParser.swift
//  machApp
//
//  Created by lukas burns on 6/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

class ErrorParser {

    func getError(networkError: NetworkError) -> ApiError {
        guard let statusCode = HttpStatusCode(rawValue: networkError.statusCode) else { return ApiError.defaultError(message: networkError.defaultErrorMessage ?? "") }

        switch statusCode {
        case .Http_NoInternetConnection:
            return ApiError.connectionError()
        case .Http401_Unauthorized:
            if let type = networkError.errorType, type == "auth_blacklisted_user" {
                NotificationCenter.default.post(name: .UserBlackListed, object: nil)
            } else {
                NotificationCenter.default.post(name: .UserLoggedOut, object: nil)
            }
            return ApiError.unauthorizedError()
        case .Http_TimeOutError:
            return ApiError.timeOutError()
        case .Http403_Forbidden:
            if let message = networkError.errorMessage {
                return ApiError.smyteError(message: message)
            } else {
                return ApiError.smyteError(message: "Esta acción ha sido bloqueada por seguridad. Comunícate con nosotros para más información.")
            }
        case .Http404_NotFound:
            if let errorType = networkError.errorType, errorType == "auth_missing_encryption_keys_error" {
                APISecurityManager.sharedInstance.createCipherKeyIfNotPresent(shouldForceCreate: true)
            }
            return ApiError.defaultError(message: networkError.defaultErrorMessage ?? "")
        case .Http503_ServiceUnavailable:
            return ApiError.serviceUnavailable()
        default:
            return ApiError.defaultError(message: networkError.defaultErrorMessage ?? "")
        }
    }

    func getError(error: Error) -> ApiError {
        return ApiError.defaultError(message: error.localizedDescription)
    }
}

class ChallengeErrorParser: ErrorParser {
    override func getError(networkError: NetworkError) -> ApiError {
        if networkError.errorType == "authentication_process_failed_error" ||
            networkError.errorType == "authentication_process_not_found_error" ||
            networkError.errorType == "authentication_process_expired_error" ||
            networkError.errorType == "authentication_challenge_no_attempts_left_error" ||
            networkError.errorType == "authentication_challenge_not_found_error" ||
            networkError.errorType == "authentication_challenge_expired_error" ||
            networkError.errorType == "authentication_challenge_already_completed_error" ||
            networkError.errorType == "authentication_provided_data_missing" {
            return ApiError.processFailedError(message: networkError.errorMessage ?? "")
        } else {
            return super.getError(networkError: networkError)
        }
    }
}

enum ApiError: Error {

    case connectionError()

    case unauthorizedError()

    case serverError(error: Error)

    case clientError(error: Error)

    case timeOutError()

    case smyteError(message: String)

    case JSONSerializationError(message: String)

    case defaultError(message: String)

    case serviceUnavailable()
    
    case processFailedError(message: String)
}

//
//  NetworkError.swift
//  machApp
//
//  Created by lukas burns on 2/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct NetworkError {
    var statusCode: Int = -1
    var defaultErrorMessage: String?
    var errorBody: JSON?
    var response: AnyObject?
    var endpoint: String?
    var errorType: String?
    var errorMessage: String?

    init(status: Int = -1, error: String? = nil, data: AnyObject? = nil ) {
        statusCode = status
        defaultErrorMessage = error
        errorBody = JSON.null
    }

    func printDescription() {
        print("Status code: \(self.statusCode), \n body: \(errorBody ?? "No Body"), \n response: \(response?.text ?? "No Response")")
    }

    func detailedError() -> String {
        return "StatusCode: \(self.statusCode): \(errorBody ?? "No Body") Endpoint: \(self.endpoint ?? "No Endpoint In Error")"
    }
}

extension NetworkError {

    init(response: DataResponse<Any>) {
        self.response = response as AnyObject

        if let value = response.data {
            errorBody = JSON(value)
            errorType = errorBody?["error"]["type"].stringValue
            errorMessage = errorBody?["error"]["message"].stringValue
        }

        // Check if an error occurred and initialize the errorMessage property.
        if let response = response.result.error {
            defaultErrorMessage = response.localizedDescription
        }

        if let code =  response.response?.statusCode {
            statusCode = code
        }

        if let requestEndpoint = response.request?.url?.absoluteString {
            endpoint = requestEndpoint
        }
    }
}

//
//  HttpStatusCode.swift
//  machApp
//
//  Created by lukas burns on 3/1/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

public enum HttpStatusCode: Int {
    // swiftlint:disable identifier_name
    // MARK: Success Codes.

    /**
     Standard response for succesfull HTTP request. The actual response will depend on the request method used.
     In a GET request, the response will contain an entity corresponding to the requested resourse.
     In a POST request the response will contain an entity describing or containing the result of the action.
    **/
    case Http_NoInternetConnection = -1

    case Http200_OK = 200

    /**
     The request has been fulfilled and resulted in a new resource being created.
    **/
    case Http201_Created = 201
    case Http202_Accepted = 202

    // MARK: Client Error Codes.
    /*
     The request cannot be fulfilled due to bad syntax.
    **/
    case Http400_BadRequest = 400

    /**
     Error code response for missing or invalid authentication token.
    **/
    case Http401_Unauthorized = 401

    /**
     The request was a legal request, but the server is refusing to respond to it. 
     Unlike a 401 Unauthorized response, authenticating will make no difference.
    **/
    case Http403_Forbidden = 403

    /**
     The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissible.
    **/
    case Http404_NotFound = 404

    // MARK: Server-side Error Codes.

    /**
     The general catch-all error when the server-side throws an exception
    **/
    case Http500_InternalServerError = 500
    case Http501_NotImplemented = 501
    case Http502_BadGateaway = 502
    case Http503_ServiceUnavailable = 503 // Nexmo Error.

    case Http_TimeOutError = -1001

    public var isSuccess: Bool {
        return self.rawValue >= 200 && self.rawValue <= 299
    }

    public var isClientError: Bool {
        return self.rawValue >= 400 && self.rawValue <= 499
    }

    public var isServerError: Bool {
        return self.rawValue >= 500 && self.rawValue <= 599
    }
}

//
//  WebPayURLResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 10/31/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Unbox
import SwiftyJSON

public struct WebPayURLResponse {
    fileprivate(set) var urlString: String
    fileprivate(set) var token: String
    fileprivate(set) var responseURL: String

    var baseURL: URL {
        //swiftlint:disable:next force_unwrapping
        return  URL(string: urlString)!.deletingPathExtension()
    }

    var urlRequest: URLRequest {
        //swiftlint:disable:next force_unwrapping
        var request = URLRequest(url: URL(string: urlString)!)

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "TBK_TOKEN=\(token)".data(using:String.Encoding.ascii, allowLossyConversion: false)
        request.httpBody = body
        return request
    }
}

extension WebPayURLResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.urlString = try unboxer.unbox(key: Constants.WebPay.AddCreditCard.url)
        self.token = try unboxer.unbox(key: Constants.WebPay.AddCreditCard.token)
        self.responseURL = try unboxer.unbox(key: Constants.WebPay.AddCreditCard.responseURL)
    }

    public static func create(from dictionary: JSON) throws -> WebPayURLResponse {
        guard let dictionaryObject = dictionary.dictionaryObject else {
            throw ApiError.JSONSerializationError(message: "There was an issue getting object from JSON.")
        }
        let response: WebPayURLResponse = try unbox(dictionary: dictionaryObject)
        return response
    }
}

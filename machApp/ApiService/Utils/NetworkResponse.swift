//
//  NetworkResponse.swift
//  machApp
//
//  Created by lukas burns on 2/16/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct NetworkResponse {

    var statusCode: Int = 200
    var response: AnyObject?
    var body: JSON?

    init(status: Int = 200, data: AnyObject? = nil ) {
        statusCode = status
        response = data
        body = JSON.null
    }

    func printDescription () {
        print("Status code: \(self.statusCode), \n body: \(body ?? "")")
    }

}

extension NetworkResponse {

    init(response: DataResponse<Any>) {
        self.response = response as AnyObject?

        if let value = response.result.value {
            self.body = JSON(value)
        }

        if let code =  response.response?.statusCode {
            statusCode = code
        }
    }
}

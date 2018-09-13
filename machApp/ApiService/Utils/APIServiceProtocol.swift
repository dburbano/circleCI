//
//  NetworkLayer.swift
//  machApp
//
//  Created by lukas burns on 2/15/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import SwinjectStoryboard

protocol Service { }

protocol APIServiceProtocol {
    func request(_ service: Service, onSuccess: @escaping (NetworkResponse) -> Void, onError: @escaping (NetworkError) -> Void)

    func requestData(_ url: URLRequest, onSuccess: @escaping (NetworkResponse) -> Void, onError: @escaping (NetworkError) -> Void)

    func uploadImage(_ service: Service, image: Data, onSuccess: @escaping (NetworkResponse) -> Void, onError: @escaping (NetworkError) -> Void)
    
    func requestAndDecrypt(_ service: Service, onSuccess: @escaping (JSON) -> Void, onError: @escaping (NetworkError) -> Void)
    
    func getBaseURL() -> String
}

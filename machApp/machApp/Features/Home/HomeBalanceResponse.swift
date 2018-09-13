//
//  HomeBalanceResponse.swift
//  machApp
//
//  Created by Alejandro Rodriguez on 10/9/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

enum Source {
    case endpoint
    case device
}

public struct HomeBalanceResponse {

    let convertedDate: String
    let convertedBalance: String
    let shouldRemoveDateAfterShown: Bool
    let balance: Int
}

//
//  ChallengeDelegate.swift
//  machApp
//
//  Created by Lukas Burns on 5/7/18.
//  Copyright © 2018 Sismo. All rights reserved.
//

import Foundation

protocol ChallengeDelegate: class {
    func didSucceedChallenge(authenticationResponse: AuthenticationResponse)
    func didProcessFailed(errorMessage: String)
}

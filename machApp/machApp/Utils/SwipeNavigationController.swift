//
//  SwipeNavigationController.swift
//  machApp
//
//  Created by lukas burns on 5/24/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation
import UIKit

class SwipeNavigationController: UINavigationController {

    // MARK: - Properties

    private var popRecognizer: InteractivePopRecognizer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopRecognizer()
    }

    // MARK: - Setup

    private func setupPopRecognizer() {
        popRecognizer = InteractivePopRecognizer(controller: self)
    }
}

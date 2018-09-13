//
//  SpuriousTestable.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

public protocol SpuriousTestable : class {

    var spurious: SpuriousType { get set }
    var identifier: ObjectIdentifier { get }

    func callSpurious(callIdentifier: String, with: [Any])
    func callSpurious<T>(callIdentifier: String, with: [Any]) -> T
    func stub(callIdentifier: String, yield: Any)

    func wasCalled(callIdentifier: String, _ parameters: EquatableValueType...) -> Bool

    func cleanup()
}

public extension SpuriousTestable {
    var spurious: SpuriousType {
        get {
            return SpuriousManager.sharedInstance.getOrCreateSpuriousForIdentifier(identifier: ObjectIdentifier(self))
        }
        set {
            SpuriousManager.sharedInstance.setSpurious(spurious: newValue, forIdentifier: ObjectIdentifier(self))
        }
    }

    var identifier: ObjectIdentifier {
        //swiftlint:disable:next implicit_getter
        get {
            return ObjectIdentifier(self)
        }
    }

    func callSpurious(callIdentifier: String = #function, with parameters: [Any] = []) {
        spurious.called(callIdentifier: callIdentifier, parameters)
    }

    func callSpurious<T>(callIdentifier: String = #function, with parameters: [Any] = []) -> T {
        spurious.called(callIdentifier: callIdentifier, parameters)
        //swiftlint:disable:next force_try
        return try! spurious.yield(callIdentifier: callIdentifier)
    }

    func stub(callIdentifier: String, yield: Any) {
        spurious.stub(callIdentifier: callIdentifier, yield: yield)
    }

    func wasCalled(callIdentifier: String, _ parameters: EquatableValueType...) -> Bool {
        return spurious.wasCalled(callIdentifier: callIdentifier, with: parameters)
    }

    func cleanup() {
        SpuriousManager.sharedInstance.removeSpuriousForIdentifier(identifier: ObjectIdentifier(self))
    }
}

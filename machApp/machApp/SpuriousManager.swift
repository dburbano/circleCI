//
//  SpuriousManager.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

public protocol SpuriousManagerType {
    func getSpuriousForIdentifier(identifier: ObjectIdentifier) -> SpuriousType?
    func getOrCreateSpuriousForIdentifier(identifier: ObjectIdentifier) -> SpuriousType
    func setSpurious(spurious: SpuriousType, forIdentifier: ObjectIdentifier)
    subscript(identifier: ObjectIdentifier) -> SpuriousType? { get }
}

public class SpuriousManager: SpuriousManagerType {
    public static let sharedInstance = SpuriousManager()
    //swiftlint:disable:next syntactic_sugar
    private var spuriousInstances: Dictionary<ObjectIdentifier, SpuriousType> = [:]

    public subscript(identifier: ObjectIdentifier) -> SpuriousType? {
        return spuriousInstances[identifier]
    }

    public func getSpuriousForIdentifier(identifier: ObjectIdentifier) -> SpuriousType? {
        return spuriousInstances[identifier]
    }

    public func getOrCreateSpuriousForIdentifier(identifier: ObjectIdentifier) -> SpuriousType {
        if spuriousInstances[identifier] == nil {
            spuriousInstances[identifier] = Spurious(identifier)
        }
        //swiftlint:disable:next force_unwrapping
        return spuriousInstances[identifier]!
    }

    public func setSpurious(spurious: SpuriousType, forIdentifier identifier: ObjectIdentifier) {
        spuriousInstances[identifier] = spurious
    }

    public func removeSpuriousForIdentifier(identifier: ObjectIdentifier) {
        spuriousInstances.removeValue(forKey: identifier)
    }
}

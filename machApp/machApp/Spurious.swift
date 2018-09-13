//
//  Spurious.swift
//  machApp
//
//  Created by Nicolas Palmieri on 5/25/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

public protocol SpuriousType : class {
    func called(callIdentifier: String, _ parameters: [Any])
    func stub(callIdentifier: String, yield: Any)
    func yield<T>(callIdentifier: String) throws -> T
    func wasCalled(callIdentifier: String, with: [EquatableValueType]) -> Bool
}

public protocol SpuriousLoggerType {
    func logFailureDetail(detail: String)
}

public class Spurious: SpuriousType, CustomStringConvertible {

    private class Logger: SpuriousLoggerType {}

    public var calls: [SpuriousCall] = []
    var stubs: [SpuriousStub] = []
    var testSubjects: [ObjectIdentifier] = []
    public var logger: SpuriousLoggerType = Logger()

    public init() {}

    public init(_ objectIdentifier: ObjectIdentifier) {
        testSubjects.append(objectIdentifier)
    }

    public func called(callIdentifier: String, _ parameters: [Any]) {
        calls.append(SpuriousCall(callIdentifier: callIdentifier, parameters: parameters))
    }

    public func stub(callIdentifier: String, yield: Any) {
        let newStub = SpuriousStub(callIdentifier, yield: yield)

        var stub = findStub(callIdentifier: callIdentifier)
        stub != nil ? stub = newStub : stubs.append(newStub)
    }

    public func yield<T>(callIdentifier: String) throws -> T {
        if let stub = findStub(callIdentifier: callIdentifier) {
            //swiftlint:disable:next force_cast
            return stub.yield as! T
        } else {
            throw SpuriousError.NoStub(callIdentifier: callIdentifier, subjects: testSubjects)
        }
    }

    public func wasCalled(callIdentifier: String, with parameters: [EquatableValueType]) -> Bool {
        guard verifyHasReceivedCalls() else {
            return false
        }

        let callsMatchingIdentifier = callsForIdentifier(callIdentifier: callIdentifier)
        guard verifyHasReceivedCalls(fromCalls: callsMatchingIdentifier, callIdentifier: callIdentifier) else {
            return false
        }

        let matchingCall = findCall(fromCalls: callsMatchingIdentifier, with: parameters)
        guard verifyMatchingCall(call: matchingCall, callIdentifier: callIdentifier, callsMatchingIdentifier: callsMatchingIdentifier) else {
            return false
        }

        return true
    }

    public func callsForIdentifier(callIdentifier: String) -> [SpuriousCall] {
        return calls.filter { (call) -> Bool in
            call.callIdentifier == callIdentifier
        }
    }

    public var description: String {
        return "<Spurious> \(ObjectIdentifier(self).hashValue) calls: \(self.calls.count) stubs: \(self.stubs.count)"
    }

}

extension Spurious {

    public func findStub(callIdentifier: String) -> SpuriousStub? {
        let index = stubs.index { (stub) -> Bool in
            stub.callIdentifier == callIdentifier
        }
        //swiftlint:disable:next force_unwrapping
        return index != nil ? stubs[index!] : nil
    }

    public func findCall(fromCalls: [SpuriousCall], with parameters: [EquatableValueType]) -> SpuriousCall? {
        let index = fromCalls.index { (call) -> Bool in
            if parameters.count != call.parameters?.count {
                return false
            }
            for i in 0 ..< parameters.count {
                let expectedParameter = parameters[i]
                //swiftlint:disable:next force_unwrapping
                let calledParameter = call.parameters![i]

                if !expectedParameter.isEqualTo(value: calledParameter) {
                    return false
                }
            }

            return true
        }
        //swiftlint:disable:next force_unwrapping
        return index != nil ? fromCalls[index!] : nil
    }

}

extension Spurious {
    fileprivate func verifyHasReceivedCalls() -> Bool {
        if calls.isEmpty {
            logger.logFailureDetail(detail: "<Spurious> There have been no recorded calls")
            return false
        }
        return true
    }

    fileprivate func verifyHasReceivedCalls(fromCalls: [SpuriousCall], callIdentifier: String) -> Bool {
        if fromCalls.isEmpty {
            logger.logFailureDetail(detail: "<Spurious> No calls identified by '\(callIdentifier)'. Received calls:\n\(calls)")
            return false
        }
        return true
    }

    fileprivate func verifyMatchingCall(call: SpuriousCall?, callIdentifier: String, callsMatchingIdentifier: [SpuriousCall]) -> Bool {
        if call == nil {
            logger.logFailureDetail(detail: "<Spurious> No calls with matching parameters for identifier '\(callIdentifier)'. Received calls:\n\(callsMatchingIdentifier)")
            return false
        }
        return true
    }
}

extension SpuriousLoggerType {
    func logFailureDetail(detail: String) {
        print(detail)
    }
}

public class SpuriousCall: CustomStringConvertible {

    let callIdentifier: String
    var parameters: [Any]?

    public var description: String {
        //swiftlint:disable:next force_unwrapping
        return "<SpuriousCall> \(ObjectIdentifier(self).hashValue) identifier: '\(self.callIdentifier)' parameters: \(self.parameters!)"
    }

    public init(callIdentifier: String, parameters: [Any]?) {
        self.callIdentifier = callIdentifier
        self.parameters = parameters
    }
}

public class SpuriousStub {
    let callIdentifier: String
    let yield: Any

    init(_ callIdentifier: String, yield: Any) {
        self.callIdentifier = callIdentifier
        self.yield = yield
    }
}

//swiftlint:disable identifier_name
public enum SpuriousError: Error, CustomStringConvertible {
    case NoStub(callIdentifier: String, subjects: [ObjectIdentifier])

    public var description: String {
        //swiftlint:disable:next implicit_getter
        get {
            switch self {
            case let .NoStub(callIdentifier, subjects):
                return "There is no stub registered for (\(callIdentifier)) with test subjects: \(subjects)"
            }
        }
    }
}

extension ObjectIdentifier: CustomStringConvertible {
    public var description: String {
        //swiftlint:disable:next implicit_getter
        get {
            return "ObjectIdentifier: \(self.hashValue)"
        }
    }
}

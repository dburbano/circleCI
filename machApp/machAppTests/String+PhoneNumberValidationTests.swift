//
//  StringPhoneNumberValidationTests.swift
//  machApp
//
//  Created by lukas burns on 3/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

import XCTest
@testable import machApp

class PhoneNumberValidationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func test_isValidPhoneNumber_phoneNumberIsEmpty_returnsFalse() {
        //Arrange
        let sut = ""
        //Act
        let isValidPhoneNumber = sut.isValidPhoneNumber
        //Assert
        XCTAssertFalse(isValidPhoneNumber, "Expected result is false for empty phoneNumber")
    }
    
    func test_isValidPhoneNumber_phoneNumberHasNonNumericCharacters_returnsFalse() {
        //Arrange
        let sut = "123123ad123"
        //Act
        let isValidPhoneNumber = sut.isValidPhoneNumber
        //Assert
        XCTAssertFalse(isValidPhoneNumber, "Expected result is false for empty phoneNumber")
    }
    
    func test_isValidPhoneNumber_phoneNumberDoesntStartsWith569_returnsFalse() {
        //Arrange
        let sut = "45682885161"
        //Act
        let isValidPhoneNumber = sut.isValidPhoneNumber
        //Assert
        XCTAssertFalse(isValidPhoneNumber, "Expected result is false for empty phoneNumber")
    }
    
   func test_isValidPhoneNumber_phoneNumberLessThan11Digits_returnsFalse() {
        //Arrange
        let sut = "1232321"
        //Act
        let isValidPhoneNumber = sut.isValidPhoneNumber
        //Assert
        XCTAssertFalse(isValidPhoneNumber, "Expected result is false for phoneNumber < 11 digits")
    }
    
    func test_isValidPhoneNumber_phoneNumberMoreThan11Digits_returnsFalse() {
        //Arrange
        let sut = "123456789101112"
        //Act
        let isValidPhoneNumber = sut.isValidPhoneNumber
        //Assert
        XCTAssertFalse(isValidPhoneNumber, "Expected result is false for phoneNumber without 569")
    }
    
    func test_isValidPhoneNumber_correctPhoneNumber_returnsTrue() {
        //Arrange
        let sut = "56982885161"
        //Act
        let isValidPhoneNumber = sut.isValidPhoneNumber
        //Assert
        XCTAssertTrue(isValidPhoneNumber, "Expected result is true for correct phoneNumber")
    }
}

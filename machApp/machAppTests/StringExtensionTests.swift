//
//  StringTests.swift
//  machApp
//
//  Created by lukas burns on 5/2/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

import XCTest
@testable import machApp

class StringExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }

    func test_removeWhisteSpaces_stringWithWitheSpaces_removesAllWhitespaces() {
        //Arrange
        let sut = "123 123123 123123 23123"
        //Act
        let resultString = sut.removeWhitespaces()
        //Assert
        XCTAssertFalse(resultString.contains(" "), "Expected result empty whitespaces for removeWhiteSpaces")
    }
    
    func test_cleanPhoneNumber_dirtyPhone_cleansSuccessfull() {
        //Arrange
        let sut = "+569 8 288 5161"
        //Act
        let resultString = sut.cleanPhoneNumber()
        //Assert
        let cleanResult = !resultString.contains(" ") && !resultString.contains("+")
        XCTAssertTrue(cleanResult, "Expected result phone number should be clean for cleanPhoneNumber")
    }
    

}

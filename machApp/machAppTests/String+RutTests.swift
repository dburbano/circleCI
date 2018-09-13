//
//  RutValidationTests.swift
//  machApp
//
//  Created by lukas burns on 2/22/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import XCTest
@testable import machApp

class RutValidationTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func test_isValidRut_rutIsEmpty_returnsFalse() {
        //Arrange
        let sut = ""
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssertFalse(isRutValid, "Expected result is false for empty rut")
    }
    
    func test_isValidRut_correctRutWithKAsDV_returnsTrue() {
        //Arrange
        let sut = "18.019.150-K"
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssert(isRutValid, "Expected result is true for correct rut")
    }
    
    func test_isValidRut_correctRutWithNumberAsDV_returnsTrue() {
        //Arrange
        let sut = "17.697.567-9"
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssert(isRutValid, "Expected result is true for correct rut")
    }
    
    func test_isValidRut_incorrectDV_returnsFalse() {
        //Arrange
        let sut = "18.019.150-4"
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssertFalse(isRutValid, "Expected result is false for incorrect DV")
    }
    
    func test_isValidRut_rutLessThan8Digits_returnsFalse() {
        //Arrange
        let sut = "18.019.15"
        //Act
        let isRutValid = sut.isValidRut
        //Arrange
        XCTAssertFalse(isRutValid, "Expected result is false for rut with less than 8 characters")
    }
    
    func test_isValidRut_nonNumericRut_returnsFalse() {
        //Arrange
        let sut = "18.1k2.150-K"
        //Act
        let isRutValid = sut.isValidRut
        //Arrange
        XCTAssertFalse(isRutValid, "Expected result is false for non numeric rut")
    }
    
    func test_isValidRut_incorrectDVFormat_returnsFalse() {
        //Arrange
        let sut = "18.019.150-I"
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssertFalse(isRutValid, "Expected result is false from incorrect DV Format")
    }
    
    func test_isValidRut_strangeCharactersInRut_returnsFalse() {
        //Arrange
        let sut = "18.0$4.123-K"
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssertFalse(isRutValid, "Expected result is false for strange characters in rut")
    }
    
    func test_isValidRut_correctRutWithouDots_returnsTrue() {
        //Arrange
        let sut = "18019150-K"
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssert(isRutValid, "Expected result is true for correct rut without dots")
    }
    
    func test_isValidRut_correctRutWithoutDash_returnsTrue() {
        //Arrange
        let sut = "18.019.150K"
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssert(isRutValid, "Expected result is true for correct rut without dash")
    }
    
    func test_isValidRut_correctRutWithoutDashAndDots_returnsTrue() {
        //Arrange
        let sut = "18019150K"
        //Act
        let isRutValid = sut.isValidRut
        //Assert
        XCTAssert(isRutValid, "Expected result is true for correct rut without dash and dots")
    }
    
    // To Rut Format

    func test_toRutFormat_lenghtLessThan8_returnsSameString() {
        // Arrange
        let sut = "1234567"
        let expectedRut = "1234567"
        // Act
        let formattedRut = sut.toRutFormat()
        // Assert
        XCTAssertTrue(expectedRut == formattedRut, "Expected result is different from inputted string")
    }

    func test_toRutFormat_largerThan9_returnsSameString() {
        // Arrange
        let sut = "1234567890"
        let expectedRut = "1234567890"
        // Act
        let formattedRut = sut.toRutFormat()
        // Assert
        XCTAssertTrue(expectedRut == formattedRut, "Expected result is different from inputted string")
    }

    func test_toRutFormat_rutWithLowerCasek_returnsRutWithUpperCaseK() {
        // Arrange
        let sut = "1234567k"
        let expectedRut = "1.234.567-K"
        // Act
        let formattedRut = sut.toRutFormat()
        // Assert
        XCTAssertTrue(expectedRut == formattedRut, "Expected result is different from inputted string with lower k")
    }

    func test_toRutFormat_rutWith8Digits_returnsCorrectFormatterRut() {
        // Arrange
        let sut = "12345678"
        let expectedRut = "1.234.567-8"
        // Act
        let formattedRut = sut.toRutFormat()
        // Assert
        XCTAssertTrue(expectedRut == formattedRut, "Expected result is different from inputted string for length 8")
    }
    
    func test_toRutFormat_rutWith9Digits_returnsCorrectFormatterRut() {
        // Arrange
        let sut = "123456789"
        let expectedRut = "12.345.678-9"
        // Act
        let formattedRut = sut.toRutFormat()
        // Assert
        XCTAssertTrue(expectedRut == formattedRut, "Expected result is different from inputted string for length 9")
    }
    
    func test_toRutFormat_correctRutWithZeroAsDv_returnsTrue() {
        // Arrange
        let sut = "201047080"
        // Act
        let isRutValid = sut.isValidRut
        // Assert
        XCTAssertTrue(isRutValid, "Expected result is false for correct rut ending in 0")
    }
    
}

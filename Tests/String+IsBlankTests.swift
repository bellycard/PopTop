//
//  String+IsBlankTests.swift
//  PopTop
//
//  Created by AJ Self on 1/29/16.
//  Copyright © 2016 Belly. All rights reserved.
//

import XCTest
@testable import PopTop

class String_IsBlankTests: XCTestCase {
    
  func testEmptyStringShouldBeTrue() {
    let testStr = ""

    XCTAssertTrue(testStr.isBlank, "Empty string should report as blank")
  }

  func testStringOfWhiteSpacesShouldBeTrue() {
    let testStr = "   "

    XCTAssertTrue(testStr.isBlank, "String of white space only should report as blank")
  }

  func testStringOfAlphanumericCharactersIsNotBlank() {
    let testStr = "Hey...123"
    let otherStr = "This string has white space but isn't blank"

    XCTAssertFalse(testStr.isBlank, "Alphanumeric string should not report as blank")
    XCTAssertFalse(otherStr.isBlank, "Alphanumeric string with white spaces should not report as blank")
  }
    
}

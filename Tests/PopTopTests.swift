//
//  PopTopTests.swift
//  PopTopTests
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import XCTest
@testable import PopTop

class PopTopTests: XCTestCase {
    func testManagerSharedInstances() {
        // Given/When
        let sharedInstance = PopTop.Manager.sharedInstance
        
        // Then
        XCTAssertNotNil(sharedInstance, "There should be a shared instance")
    }
}

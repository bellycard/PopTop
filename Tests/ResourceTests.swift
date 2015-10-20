//
//  ResourceTests.swift
//  PopTop
//
//  Created by AJ Self on 10/20/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import XCTest
@testable import PopTop

class ResourceTests: XCTestCase {

    func testShouldSetPropertiesOnDesignatedInitializer() {
        // Given
        let id = "/path/to/good/times"
        let type = "fake type"
        let resource = Resource(resourceIdentifier: id, mimeType: type)
        
        // Then
        XCTAssertEqual(resource.resourceIdentifier, id, "Resource identifier should be set and valid")
        XCTAssertEqual(resource.mimeType, type, "Mime type should be set and valid")
    }

}

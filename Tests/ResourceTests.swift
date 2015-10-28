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
        let resource = Resource(resourceIdentifier: id, contentType: type)
        
        // Then
        XCTAssertEqual(resource.resourceIdentifier, id, "Resource identifier should be set and valid")
        XCTAssertEqual(resource.contentType, type, "Mime type should be set and valid")
    }
    
    func testShouldSetPropertiesOnConvenienceInitializer() {
        // Given
        let id = "/path/to/really/cool/resource"
        let resource = Resource(resourceIdentifier: id)
        
        // Then
        XCTAssertEqual(resource.resourceIdentifier, id, "Resource identifier should be set and valid")
        XCTAssertEqual(resource.contentType, "application/json; charset=utf-8", "Mime type should be set and valid")
    }
    
    func testShouldHaveDataAndID() {
        // Given
        class TestResource: Resource {
            override func data() -> (resourceData: NSData?, resourceID: Int?) {
                let testInfo = ["foo": "bar"]
                let testData = try! NSJSONSerialization.dataWithJSONObject(testInfo, options: NSJSONWritingOptions())
                return (testData, 123)
            }
        }
        
        // When
        let resource = TestResource(resourceIdentifier: "/path")
        
        let data = resource.data()
        
        // Then
        
        XCTAssert((data.resourceData! as Any) is NSData, "Resource data should not be nil and be a valid NSData object")
        XCTAssertEqual(data.resourceID, 123, "Resource IDs should match")
    }
}

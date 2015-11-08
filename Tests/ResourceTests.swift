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
        let resourceID = "/path/to/good/times"
        let type = "fake type"
        
        // When
        let resource = Resource(resourceIdentifier: resourceID, contentType: type)
        
        // Then
        XCTAssertEqual(resource.resourceIdentifier, resourceID, "Resource identifier should be set and valid")
        XCTAssertEqual(resource.contentType, type, "Mime type should be set and valid")
        XCTAssertTrue(resource.isREST, "Resource should be a RESTful resource by default")
        XCTAssertEqual(resource.URL, NSURL(string: resourceID), "Resource URL should be set and valid")
    }
    
    func testShouldSetIsRestToFalseOnInit() {
        // Given
        let resourceID = "/path/to/good/times"
        let type = "fake type"
        
        // When
        let resource = Resource(resourceIdentifier: resourceID, contentType: type, isREST: false)
        
        // Then
        XCTAssertFalse(resource.isREST, "isREST should be set to false")
        
        // When
        resource.isREST = true
        
        // Then
        XCTAssertTrue(resource.isREST, "isREST should be true")
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

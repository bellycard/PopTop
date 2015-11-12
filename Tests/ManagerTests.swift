//
//  ManagerTests.swift
//  PopTopTests
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import XCTest
@testable import PopTop
import SwiftyJSON

class ManagerTests: XCTestCase {
    let manager = PopTop.Manager
    
    override func setUp() {
        super.setUp()
        
        manager.removeResources()
    }
    
    override func tearDown() {
        NSURLProtocol.unregisterClass(PopTop.Manager)
        super.tearDown()
    }

    // MARK: - Helpers

    class ResourceWithData: ResourceProtocol {
        let resourceIdentifier: String
        let contentType = "fake type"

        init(resourceIdentifier: String) {
            self.resourceIdentifier = resourceIdentifier
        }

        func data(request: NSURLRequest) -> NSData {
            let testData: JSON = [["id": "123", "foo": "bar"]]
            return try! testData.rawData()
        }
    }

    func setUpFakeRequest() -> NSURLRequest {
        let testResource = ResourceWithData(resourceIdentifier: "/path/to/example")
        manager.addResources(testResource)
        NSURLProtocol.registerClass(PopTop.Manager)
        return NSURLRequest(URL: NSURL(string: testResource.resourceIdentifier)!)
    }

    // MARK: - Class Tests

    func testShouldContainCollectionOfResources() {
        let firstResource = ResourceWithData(resourceIdentifier: "/path/to/first")
        let secondResource = ResourceWithData(resourceIdentifier: "/path/to/second")
        
        manager.addResources(firstResource, secondResource)

        XCTAssertEqual(manager.count, 2, "Resources should be stored")
    }
    
    func testShouldReturnTrueForMatchedPath() {
        // Given
        let request = setUpFakeRequest()

        // When
        let result = manager.canInitWithRequest(request)

        // Then
        XCTAssertTrue(result, "PopTop should handle a known host")
    }

    func testShouldReturnFalseForUnknownPath() {
        // Given
        manager.addResources(ResourceWithData(resourceIdentifier: "/path/to/first"), ResourceWithData(resourceIdentifier: "/path/to/second"))
        let request = NSURLRequest(URL: NSURL(string: "/path/to/nowhere")!)

        // When
        let result = manager.canInitWithRequest(request)

        // Then
        XCTAssertFalse(result, "PopTop should pass on an unknown host")

    }
    
    func testShouldAddMoreDomainsOnTheFly() {
        // Given
        let firstResource = ResourceWithData(resourceIdentifier: "/one")
        let secondResource = ResourceWithData(resourceIdentifier: "/two")
        let firstRequest = NSURLRequest(URL: NSURL(string: firstResource.resourceIdentifier)!)
        let secondRequest = NSURLRequest(URL: NSURL(string: secondResource.resourceIdentifier)!)

        // When
        manager.addResources(firstResource)
        let firstResult = manager.canInitWithRequest(firstRequest)

        manager.addResources(secondResource)
        let secondResult = manager.canInitWithRequest(secondRequest)

        // Then
        XCTAssertTrue(firstResult)
        XCTAssertTrue(secondResult, "PopTop should allow the addition of more URLs")
    }
    
    func testResourceNameAndIDFromURLShouldReturnNameAndNil() {
        // Given
        let url = NSURL(string: "/path/to/resource")

        // When
        let nameAndID = Manager.resourceNameAndIDFromURL(url!)

        // Then
        XCTAssertEqual(nameAndID.name!, "/path/to/resource", "Relative path should be returned")
        XCTAssertNil(nameAndID.id, "ID should be nil")
    }
}
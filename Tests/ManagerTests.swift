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

        func data(request: NSURLRequest, resourceArtifacts: ResourceArtifacts) -> NSData {
            let id = resourceArtifacts.ids!.first!
            let testData: JSON = [["id": id, "foo": "bar"]]
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
        // Given
        let firstResource = ResourceWithData(resourceIdentifier: "/path/to/first")
        let secondResource = ResourceWithData(resourceIdentifier: "/path/to/second")

        // When
        manager.addResources(firstResource, secondResource)

        // Then
        XCTAssertEqual(manager.count, 2, "Resources should be stored")
    }

    func testShouldRemoveASingleResource() {
        // Given
        let firstResource = ResourceWithData(resourceIdentifier: "/path/to/first")

        // When
        manager.addResources(firstResource)

        // Then
        XCTAssertEqual(manager.count, 1, "Should contain a resource")

        // When
        manager.removeResource(firstResource)

        // Then
        XCTAssertEqual(manager.count, 0, "Should be empty")
    }
    
    func testShouldReturnTrueForMatchedPath() {
        // Given
        let request = setUpFakeRequest()

        // When
        let result = manager.canInitWithRequest(request)

        // Then
        XCTAssertTrue(result, "PopTop should handle a known host")
    }

    func testShouldReturnTrueForPathsWithID() {
        // Given
        let testResource = ResourceWithData(resourceIdentifier: "/path/to/:id/example")
        let testResource2 = ResourceWithData(resourceIdentifier: "/path/to/:id/example/with/:id/another")

        NSURLProtocol.registerClass(PopTop.Manager)
        manager.addResources(testResource, testResource2)

        let testRequest = NSURLRequest(URL: NSURL(string: "https://api.example.com/path/to/123/example")!)
        let testRequest2 = NSURLRequest(URL: NSURL(string: "https://api.example.com/path/to/123/example/with/456/another")!)

        // When
        let result = manager.canInitWithRequest(testRequest)
        let result2 = manager.canInitWithRequest(testRequest2)

        // Then
        XCTAssertTrue(result, "PopTop should handle :id in paths")
        XCTAssertTrue(result2, "PopTop should handle :id in paths")
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
    
    func testResourceArtifactsFromRequestShouldReturnNameAndNil() {
        // Given
        let url = NSURL(string: "/path/to/resource")!
        let request = NSURLRequest(URL: url)

        // When
        let resourceArtifcats = Manager.resourceArtifactsFromRequest(request)

        // Then
        XCTAssertEqual(resourceArtifcats!.name, "/path/to/resource", "Relative path should be returned")
        XCTAssertNil(resourceArtifcats!.ids, "ID should be nil")
        XCTAssertNil(resourceArtifcats!.query, "Query should be nil")
    }

    func testResourceArtifactsFromRequestShouldReturnSingleID() {
        // Given
        let url = NSURL(string: "/path/123/to/resource")!
        let request = NSURLRequest(URL: url)

        // When
        let resourceArtifacts = Manager.resourceArtifactsFromRequest(request)

        // Then
        XCTAssertEqual(resourceArtifacts!.ids!, [123], "Correct ID should be returned")

    }

    func testResourceArtifactsFromRequestShouldReturnMultipleIDs() {
        // Given
        let url = NSURL(string: "/path/123/to/resource/456")!
        let request = NSURLRequest(URL: url)

        // When
        let resourceArtifacts = Manager.resourceArtifactsFromRequest(request)

        // Then
        XCTAssertEqual(resourceArtifacts!.ids!, [123, 456], "Two IDs, in order, should be returned")
    }

    func testResourceArtifactsFromRequestShouldReturnQueryParams() {
        // Given
        let url = NSURL(string: "/path/to/123/resource?foo=bar&baz=quux&foo=biz")!
        let request = NSURLRequest(URL: url)

        // When
        let resourceArtifacts = Manager.resourceArtifactsFromRequest(request)

        // Then
        XCTAssertNotNil(resourceArtifacts!.query, "Query should be populated")
        XCTAssertEqual(resourceArtifacts!.query!, ["foo": ["bar", "biz"], "baz": ["quux"]], "Query dictionary should be correct")
    }

    func testResourceArtifactsFromRequestShouldNotReturnKeyForInvalidQueryParam() {
        // Given
        let url = NSURL(string: "/path/to/123/resource?foo=&bar=baz&123!!")!
        let request = NSURLRequest(URL: url)

        // When
        let resourceArtifacts = Manager.resourceArtifactsFromRequest(request)

        // Then
        XCTAssertEqual(resourceArtifacts!.query!, ["bar": ["baz"]], "Returned dictionary should only have one value")
    }

    func testResourceArtifactsFromRequestShouldReturnNilForEmptyNSURL() {
        // Given
        let url = NSURL(string: "")!
        let request = NSURLRequest(URL: url)

        // When
        let resourceArtifacts = Manager.resourceArtifactsFromRequest(request)

        // Then
        XCTAssertNil(resourceArtifacts)
    }

    // Skip this test for now due to a bug where HTTPBody is set to nil when PopTop receives the NSURLRequest
    // http://openradar.appspot.com/15993891
    func xtestResourceArtifactsFromRequestShouldReturnBodyData() {
        let testRequest = NSMutableURLRequest(URL: NSURL(string: "https://example.com/path/to/123/resource")!)
        let session = NSURLSession.sharedSession()
        let params = ["id": "123", "name": "Test User"]
        let expect = expectationWithDescription("Test")

        testRequest.HTTPMethod = "POST"
        testRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        testRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        testRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        NSURLProtocol.registerClass(PopTop.Manager)

        struct TestPostResource: ResourceProtocol {
            let resourceIdentifier = "/path/to/:id/resource"
            let contentType = "fake type"

            func data(request: NSURLRequest, resourceArtifacts: ResourceArtifacts) -> NSData {
                let body = resourceArtifacts.body!
                XCTAssertEqual(body["id"]!, ["123"], "Post data should be parsed into a dictionary")
                return NSData()
            }
        }

        manager.addResources(TestPostResource())

        let task = session.dataTaskWithRequest(testRequest) { _,_,_ in
            expect.fulfill()
        }

        task.resume()

        waitForExpectationsWithTimeout(task.originalRequest!.timeoutInterval) { err in
            if let err = err {
                print("ERROR: \(err.localizedDescription)")
            }

            task.cancel()
        }
    }
}
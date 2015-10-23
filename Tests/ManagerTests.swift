//
//  ManagerTests.swift
//  PopTopTests
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import XCTest
@testable import PopTop

class ManagerTests: XCTestCase {
    let manager = PopTop.Manager
    
    override func setUp() {
        super.setUp()
        
        manager.resources = [Resource]()
    }
    
    override func tearDown() {
        NSURLProtocol.unregisterClass(PopTop.Manager)
        super.tearDown()
    }
    
    class ResourceWithData: Resource {
        override func data() -> (resourceData: NSData, resourceID: Int) {
            let testInfo = ["foo": "bar"]
            let testData = try! NSJSONSerialization.dataWithJSONObject(testInfo, options: NSJSONWritingOptions())
            return (testData, 123)
        }
    }
    
    // MARK: - Test Helpers
    
    func setUpFakeRequest() -> NSURLRequest {
        let testResource = ResourceWithData(resourceIdentifier: "/path/to/example")
        manager.resources = [testResource]
        NSURLProtocol.registerClass(PopTop.Manager)
        return NSURLRequest(URL: NSURL(string: testResource.resourceIdentifier)!)
    }
    
    func setUpNetworkTask(url: NSURL, method: String, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        return NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: handler)
    }
    
    func waitForExpectationsWithNetworkTask(networkTask: NSURLSessionDataTask) {
        waitForExpectationsWithTimeout(networkTask.originalRequest!.timeoutInterval) { err in
            if let err = err {
                print("Error: \(err.localizedDescription)")
            }
            networkTask.cancel()
        }
    }
    
    func createStoredResource(URL: NSURL, taskToResume: NSURLSessionDataTask) {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (_, _, _) in
            // When
            taskToResume.resume()
            }.resume()
    }
    
    // MARK: - Class Tests
    
    func testShouldContainArrayOfResources() {
        // Given
        let testResources = [
            // With leading slash
            Resource(resourceIdentifier: "/users/:users_id/pets/:pets_id"),
            // Without leading slash
            Resource(resourceIdentifier: "users/:users_id/earthly_posessions/:earthly_posessions_id"),
        ]
        
        // When
        manager.resources = testResources
        
        // Then
        XCTAssertEqual(manager.resources.count, 2, "Resource manager should contain resources")
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
        manager.resources = [Resource(resourceIdentifier: "/users/:users_id/pets/:pets_id"), Resource(resourceIdentifier: "users/:users_id")]
        let request = NSURLRequest(URL: NSURL(string: "/path/to/nowhere")!)
        
        // When
        let result = manager.canInitWithRequest(request)
        
        // Then
        XCTAssertFalse(result, "PopTop should pass on an unknown host")
    }
    
    func testShouldAddMoreDomainsOnTheFly() {
        // Given
        let firstResource = Resource(resourceIdentifier: "/one/")
        let secondResource = Resource(resourceIdentifier: "/two/")
        let firstRequest = NSURLRequest(URL: NSURL(string: firstResource.resourceIdentifier)!)
        let secondRequest = NSURLRequest(URL: NSURL(string: secondResource.resourceIdentifier)!)
        
        // When
        manager.resources.append(firstResource)
        let firstResult = manager.canInitWithRequest(firstRequest)
        
        manager.resources.append(secondResource)
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
    
    func testShouldCreateARegistryForGivenResource() {
        // Given
        let expectation = expectationWithDescription("Adding resource to collection")
        let expectedResourceName = "/path/to/example"
        let url = NSURL(string: "http://example.com/path/to/example")!
        
        setUpFakeRequest()
        
        // POST to create
        let networkTask = setUpNetworkTask(url, method: "POST") { [unowned self] (data, res, err) in
            // Then
            XCTAssertNotNil(self.manager.registry[expectedResourceName], "Registry with resource name should exist")
            XCTAssertNil(err, "Error should be nil")
            
            expectation.fulfill()
        }
        
        // When
        networkTask.resume()
        waitForExpectationsWithNetworkTask(networkTask)
    }
    
    func testShouldRetrieveAResourceWithID() {
        // Given
        let expectation = expectationWithDescription("Adding resource to collection")
        let postURL = NSURL(string: "http://example.com/path/to/example")!
        let getURL = NSURL(string: "https://example.com/path/to/example/123")!
        
        setUpFakeRequest()
        
        // GET to retrieve
        let networkTask = setUpNetworkTask(getURL, method: "GET") { (data, res, err) in
            // Then
            XCTAssertNotNil(data, "Returned data should be available")
            XCTAssertNil(err, "There shouldn't be any errors")
            expectation.fulfill()
        }
        
        // POST to create a resource to start
        createStoredResource(postURL, taskToResume: networkTask)
        
        // When
        waitForExpectationsWithNetworkTask(networkTask)
    }
    
    func xtestShouldUpdateAResourceWithID() {
        // Given
        let expectation = expectationWithDescription("Adding resource to collection")
        let postURL = NSURL(string: "http://example.com/path/to/example")!
        let putURL = NSURL(string: "https://example.com/path/to/example/123")!
        
        setUpFakeRequest()
        
        let getNetworkTask = setUpNetworkTask(putURL, method: "GET") { (data, res, err) in
            // Then
            expectation.fulfill()
        }
        
        // PUT to update
        let networkTask = setUpNetworkTask(putURL, method: "PUT") { (data, res, err) in
            // Then
            XCTAssertNotNil(data, "Returned data should be available")
            XCTAssertNil(err, "There shouldn't be any errors")
            getNetworkTask.resume()
        }
        
        // POST to create a resource to start
        createStoredResource(postURL, taskToResume: networkTask)
    }
    
    func xtestShouldDeleteAResourceWithID() {
        
    }
}

//
//  PopTopTests.swift
//  PopTopTests
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import XCTest
@testable import PopTop

class ManagerTests: XCTestCase {
    let manager = PopTop.Manager
    
    override func tearDown() {
        manager.resources = [String]()
        super.tearDown()
    }
    
    func setUpFakeRequest() -> NSURLRequest {
        let testUrl = "http://example.org/"
        manager.resources = [testUrl]
        let URL = NSURL(string: testUrl)!
        return NSURLRequest(URL: URL)
    }
    
    func testContainsArrayOfURLs() {
        // Given
        let testURLs = ["http://example.com", "https://www.example.org"]
        
        // When
        manager.resources = testURLs
        
        // Then
        XCTAssertEqual(manager.resources, testURLs, "PopTop should accept array of URLs")
    }
    
    func testShouldReturnFalseIfNotStarted() {
        // Given
        let request = setUpFakeRequest()
        
        // When
        let result = manager.canInitWithRequest(request)
        
        // Then
        XCTAssertFalse(result, "PopTop should return false when provided valid URLs and not started")
    }
    
    func testShouldReturnTrueIfStarted() {
        // Given
        let request = setUpFakeRequest()
        
        // When
        manager.start()
        let result = manager.canInitWithRequest(request)
        
        // Then
        XCTAssertTrue(result, "PopTop should return true when provided valid URLs and started")
    }
    
    func testShouldReturnFalseIfEnded() {
        // Given
        let request = setUpFakeRequest()
        
        // When
        manager.start()
        manager.end()
        let result = manager.canInitWithRequest(request)
        
        // Then
        XCTAssertFalse(result, "PopTop should return false when provided valid URLs and ended")
    }
    
    func testShouldReturnFalseIfRequestDoesntHaveTag() {
        // Given
        let request = setUpFakeRequest()
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        NSURLProtocol.setProperty(true, forKey: "PopTopRequestHandled", inRequest: mutableRequest)
        
        // When
        manager.start()
        let result = manager.canInitWithRequest(request)
        
        // Then
        XCTAssertTrue(result, "PopTop should return false if request has tag present")
    }
}

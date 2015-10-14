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
    
    func testShouldReturnFalseIfRequestDoesntHaveTag() {
        // Given
        let request = setUpFakeRequest()
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        NSURLProtocol.setProperty(true, forKey: "PopTopRequestHandled", inRequest: mutableRequest)
        
        // When
        let result = manager.canInitWithRequest(request)
        
        // Then
        XCTAssertTrue(result, "PopTop should return false if request has tag present")
    }
}

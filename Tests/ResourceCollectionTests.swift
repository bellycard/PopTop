//
//  ResourceCollectionTests.swift
//  PopTop
//
//  Created by AJ Self on 11/10/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import XCTest
@testable import PopTop

class ResourceCollectionTests: XCTestCase {
    
    func testShouldAcceptResources() {
        // Given
        struct TestResource: ResourceProtocol {
            let resourceIdentifier = "/path/to/resource"
            let contentType = "fake type"

            func data(request: NSURLRequest, resourceArtifacts: ResourceArtifacts) -> NSData {
                return NSData()
            }
        }

        let testResource = TestResource()
        var resourceCollection = ResourceCollection<String, ResourceProtocol>()

        // When
        resourceCollection["/path/to/test"] = testResource

        // Then
        XCTAssertEqual(resourceCollection.count, 1, "Resource collection should have 1 object")
    }

    func testShouldAllowSubscripting() {
        // Given
        struct FirstTestResource: ResourceProtocol {
            let resourceIdentifier = "/path/to/resource"
            let contentType = "fake type"

            func data(request: NSURLRequest, resourceArtifacts: ResourceArtifacts) -> NSData {
                return NSData()
            }
        }

        class SecondTestResource: ResourceProtocol {
            let resourceIdentifier = "/path/to/second/resource"
            let contentType = "test content type"
            
            func data(request: NSURLRequest, resourceArtifacts: ResourceArtifacts) -> NSData {
                return NSData()
            }
        }

        let firstTestResource = FirstTestResource()
        let secondTestResource = SecondTestResource()
        var resourceCollection = ResourceCollection<String, ResourceProtocol>()

        // When
        resourceCollection[firstTestResource.resourceIdentifier] = firstTestResource
        resourceCollection[secondTestResource.resourceIdentifier] = secondTestResource

        // Then
        XCTAssertEqual(resourceCollection["/path/to/resource"]!.resourceIdentifier, firstTestResource.resourceIdentifier, "Resource should support subscripting")
        XCTAssertEqual(resourceCollection["/path/to/second/resource"]!.resourceIdentifier, secondTestResource.resourceIdentifier, "Resource should support subscripting")
    }

    func testShouldRemoveOne() {
        // Given
        struct TestResource: ResourceProtocol {
            let resourceIdentifier = "/path/to/resource"
            let contentType = "fake type"

            func data(request: NSURLRequest, resourceArtifacts: ResourceArtifacts) -> NSData {
                return NSData()
            }
        }

        let testResource = TestResource()
        var resourceCollection = ResourceCollection<String, ResourceProtocol>()

        // When
        resourceCollection[testResource.resourceIdentifier] = testResource

        // Then
        XCTAssertEqual(resourceCollection.count, 1, "There should be one resource")

        // When
        let removedResource = resourceCollection.remove(testResource.resourceIdentifier)

        // Then
        XCTAssertEqual(resourceCollection.count, 0, "There shouldn't be any remaining resources")
        XCTAssertEqual(removedResource?.resourceIdentifier, testResource.resourceIdentifier, "Returned, removed resource should be same as initial test resource")
    }

    func testShouldRemoveAll() {
        // Given
        struct FirstTestResource: ResourceProtocol {
            let resourceIdentifier = "/path/to/resource"
            let contentType = "fake type"

            func data(request: NSURLRequest, resourceArtifacts: ResourceArtifacts) -> NSData {
                return NSData()
            }
        }

        let firstTestResource = FirstTestResource()
        var resourceCollection = ResourceCollection<String, ResourceProtocol>()

        // When
        resourceCollection[firstTestResource.resourceIdentifier] = firstTestResource
        resourceCollection.removeAll()

        // Then
        XCTAssertEqual(resourceCollection.count, 0, "Resource collection should have no objects")
    }
}

//
//  Resource.swift
//  PopTop
//
//  Created by AJ Self on 10/20/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import Foundation

public class Resource {
    /// The path to the resource that the Manager should match requests against
    public let resourceIdentifier: String
    
    /// The set response MIME type
    public let mimeType: String // TODO: Make this an enum that can be extensible
    
    /// NSURL for convenience
    let url: NSURL?
    
    /**
        Initializes a Resource with provided resource ID and MIME type
    
        - Parameters:
            - resourceIdentifier: The path to the resource that should be matched
                ```
                /path/to/resource
                /users/123/pets/456
                /admin/users/123/
                ```
            - mimeType: Expected response type
    
        - Returns: A new Resource instance set with provided parameters
    */
    init(resourceIdentifier: String, mimeType: String) {
        self.mimeType = mimeType
        self.resourceIdentifier = resourceIdentifier
        self.url = NSURL(string: resourceIdentifier)
    }
    
    /**
        Initializes a Resource with the MIME type set to "application/json; charset=utf-8".
    
        - Parameter resourceIdentifier: The path the resource should match
    
        - Returns: A new Resource instance with the MIME type set to "application/json; charset=utf-8"
    */
    convenience init(resourceIdentifier id: String) {
        self.init(resourceIdentifier: id, mimeType: "application/json; charset=utf-8")
    }
    
    /**
        NSData object that will be returned in the request representing the Resource instance.
        Subclasses are required to implement their own implementation
    */
    func data() -> NSData {
        fatalError("Subclasses are required to create their own implementation") //TODO: Fine for now but is there a better way to do this? I can haz protocols?
    }
}
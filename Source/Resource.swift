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
    public let contentType: String // TODO: Make this an enum that can be extensible
    
    /// NSURL for convenience
    let URL: NSURL?
    
    /// Determines if the resource is RESTful JSON resource. True by default.
    var isREST: Bool
    
    /**
        Initializes a Resource with provided resource ID and MIME type
    
        - Parameters:
            - resourceIdentifier: The path to the resource that should be matched
                ```
                /login
                /path/to/resource
                /users/123/pets/456
                /admin/users/123/
                /with/query?params=true
                ```
            - contentType: Expected response type
    
        - Returns: A new Resource instance set with provided parameters
    */
    public init(resourceIdentifier: String, contentType: String = "application/json; charset=utf-8", isREST: Bool = true) {
        self.contentType = contentType
        self.isREST = isREST
        self.resourceIdentifier = resourceIdentifier
        self.URL = NSURL(string: resourceIdentifier)
    }
    
    /**
        NSData object that will be returned in the request representing the Resource instance.
        Subclasses are required to create their own implementation
    
        - Returns:
            - rawData: NSData representation of object to be returned
            - id: Identifier used for storing data in the manager
    */
    public func data() -> (rawData: NSData?, id: Int?) {
        fatalError("Subclasses are required to create their own implementation") //TODO: Fine for now but is there a better way to do this? I can haz protocols? Or throw instead of fatalError?
    }
}
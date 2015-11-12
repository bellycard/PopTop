//
//  ResourceProtocol.swift
//  PopTop
//
//  Created by AJ Self on 11/10/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import Foundation

public protocol ResourceProtocol {
    /// The path to the resource that the Manager should match requests against
    var resourceIdentifier: String { get }

    /// The set response MIME type
    var contentType: String { get } // TODO: Make this an enum that can be extensible

    /**
     NSData object that will be returned in the request representing the Resource instance.
     Subclasses are required to create their own implementation

     - Returns:
     - rawData: NSData representation of object to be returned
     - id: Identifier used for storing data in the manager
     */
    func data(request: NSURLRequest) -> NSData
}
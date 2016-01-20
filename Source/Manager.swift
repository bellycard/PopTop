//
//  Manager.swift
//  PopTop
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import SwiftyJSON

public class Manager: NSURLProtocol {
    // MARK: - Properties
    
    // Holds instances of Resource subclasses and are used to check if Manager can handle an incoming request
    private static var resources = ResourceCollection<String, ResourceProtocol>()

    static var count: Int {
        return resources.count
    }
    
    // MARK: - Protocol implementation
    // Class
    override public class func canInitWithRequest(request: NSURLRequest) -> Bool {
        if let requestName = resourceNameAndIDFromURL(request.URL!).name, _ = resources[requestName] {
            return true
        }
        
        return false
    }
    
    // MARK: - Instance

    override public func startLoading() {
        /// A tuple of (key, id) that will be used within the registry dict based on the URL path
        /// `/path/to/resource/123` -> `(name: "/path/to/resource", ids: [123])`
        let pathToResourceParts = Manager.resourceNameAndIDFromURL(request.URL!)
        
        /// The Resource itself, if available.
        /// This is used to create new represetnations of a requested resource
        /// requested URL: `/path/to/resource/123` -> resource.data().rawData == {"id": 123, "foo": "bar"}
        let resource = Manager.resources[pathToResourceParts.name!]

        /// Data that will be returned in the HTTP request.
        let dataToReturn = resource!.data(request, resourceDetails: pathToResourceParts)

        let response = NSHTTPURLResponse(URL: request.URL!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: ["Content-Type": resource!.contentType])!

        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        client?.URLProtocol(self, didLoadData: dataToReturn)
        client?.URLProtocolDidFinishLoading(self)
    }
    
    /// Because PopTop always returns an object it is acceptable to leave this empty.
    override public func stopLoading() {}
    
    /// Returns unchanged request
    override public class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }

    // MARK: - Class

    /// Receives a variable amount of ResourceProtocol types that are queried when receiving an HTTP request
    static public func addResources(resourcesToAdd: ResourceProtocol...) {
        for resource in resourcesToAdd {
            resources[resource.resourceIdentifier] = resource
        }
    }

    static public func removeResources() {
        resources.removeAll()
    }
    
    // MARK: - Helpers
    
    /// Normalize a path which can be used as a Resource Identifier and requested resource ID, if available.
    /// - Returns: "/path/to/resource/123" -> ("/path/to/resource/", 123)
    static func resourceNameAndIDFromURL(url: NSURL) -> (name: String?, ids: [Int]?) {
        var pathComponents = url.pathComponents!
        var name: String?
        var ids = [Int]?()
        let separator = "/"

        // Check if the URL has an ID within it -> /api/path/to/123/example
        for (index, component) in pathComponents.enumerate() {

            // if it does...
            if let id = Int(component) {

                // add it to the IDs array to be returned
                if ids?.append(id) == nil {
                    ids = [id]
                }
                
                // remove the number and replace with predetermined key to be used for the name to be returned
                pathComponents[index] = ":id"
            }
        }

        // prevents "//" from occurring when joining the path components
        if pathComponents.first == separator {
            pathComponents.removeFirst()
        }
        
        name = pathComponents.joinWithSeparator(separator)
        name = separator + name!
        
        return (name, ids)
    }
}

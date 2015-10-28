//
//  Manager.swift
//  PopTop
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import Foundation

public class Manager: NSURLProtocol {
    // MARK: - Properties

    /// Holds instances of Resource subclasses and are used to check if Manager can handle an incoming request
    public static var resources = [Resource]()
    
    /// Holds values for individual resources
    /// Example: `/path/to/resource/123` -> `["/path/to/resource": [123: NSData]]`
    static var registry = [String: [Int: NSData]]()
    
    // MARK: - Protocol implementation
    // Class
    override public class func canInitWithRequest(request: NSURLRequest) -> Bool {
        let requestName = resourceNameAndIDFromURL(request.URL!).name
        
        for resource in resources  where resourceNameAndIDFromURL(resource.URL!).name == requestName {
            return true
        }
        
        return false
    }
    
    // Instance
    override public func startLoading() {
        let resourceDetails = Manager.resourceNameAndIDFromURL(request.URL!)
        var dataToReturn = NSData()
        let resource = Manager.resourceByResourceIdentifier(resourceDetails.name!)
        
        switch request.HTTPMethod! {
        case "GET":
            if let name = resourceDetails.name, id = resourceDetails.id {
                if let cachedRegistry = Manager.registry[name], cachedResource = cachedRegistry[id] {
                    dataToReturn = cachedResource
                } else {
                    Manager.registry[name] = [id: (resource?.data().resourceData)!]
                    dataToReturn = (resource?.data().resourceData)!
                }
            } else {
                dataToReturn = (resource?.data().resourceData)!
            }
            
        case "POST":
            if let name = resourceDetails.name, data = resource?.data()  {
                let resourceData = data.resourceData!
                let id = data.resourceID!

                Manager.registry[name] = [id: resourceData]
                dataToReturn = resourceData
            }
            
        case "DELETE":
            if let id = resourceDetails.id, name = resourceDetails.name {
                Manager.registry[name]?.removeValueForKey(id)
            }
            
        default:
            // TODO: make this throw an error
            break
        }

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
    
    // MARK: - Helpers
    /// Normalize a path which can be used as a Resource Identifier and requested resource ID, if available.
    class func resourceNameAndIDFromURL(url: NSURL) -> (name: String?, id: Int?) {
        var pathComponents = url.pathComponents!
        var name: String?
        var id: Int?
        let separator = "/"
        
        if let idProvided = Int(url.lastPathComponent!) {
            id = idProvided
            // Remove the ID from the route so the path to the resource can become its key like so:
            // /users/123/pets/456 -> ["/users/123/pets": ["456": NSData]]
            pathComponents.removeLast()
        }

        // prevents "//" from occurring when joining the path components
        if pathComponents.first == separator {
            pathComponents.removeFirst()
        }
        
        name = pathComponents.joinWithSeparator(separator)
        name = separator + name!
        
        return (name, id)
    }
    
    /// Find and return a stored resource instance by its Resource Identifier.
    class func resourceByResourceIdentifier(resourceIdentifier: String) -> Resource? {
        for resource in resources where resource.resourceIdentifier == resourceIdentifier {
            return resource
        }
        
        return nil
    }
}

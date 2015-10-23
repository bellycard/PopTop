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
    public static var resources = [Resource]()
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
            if let name = resourceDetails.name, number = resourceDetails.id {
                dataToReturn = Manager.registry[name]![number]!
            } else {
                dataToReturn = (resource?.data().resourceData)!
            }
            
        case "POST":
            if let resourceName = resourceDetails.name, data = resource?.data()  {
                let resourceData = data.resourceData!
                let resourceID = data.resourceID!

                Manager.registry[resourceName] = [resourceID: resourceData]
                dataToReturn = resourceData
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
        var resourceName: String?
        var resourceID: Int?
        let separator = "/"
        
        if let id = Int(url.lastPathComponent!) {
            resourceID = id
            // Remove the ID from the route so the path to the resource can become its key like so:
            // /users/123/pets/456 -> ["/users/123/pets": ["456": NSData]]
            pathComponents.removeLast()
        }

        // prevents "//" from occurring when joining the path components
        if pathComponents.first == separator {
            pathComponents.removeFirst()
        }
        
        resourceName = pathComponents.joinWithSeparator(separator)
        resourceName = separator + resourceName!
        
        return (resourceName, resourceID)
    }
    
    /// Find and return a stored resource instance by its Resource Identifier.
    class func resourceByResourceIdentifier(resourceIdentifier: String) -> Resource? {
        for resource in resources where resource.resourceIdentifier == resourceIdentifier {
            return resource
        }
        
        return nil
    }
}

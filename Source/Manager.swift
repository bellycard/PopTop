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
    static var registry = [String: [String: NSData]]()
    
    // MARK: - Protocol implementation
    // Class
    override public class func canInitWithRequest(request: NSURLRequest) -> Bool {
        
        for resource in resources  where resourceNameAndIDFromURL(resource.url!).name == request.URL?.relativePath {
            return true
        }
        
        return false
    }
    
    // Instance
    override public func startLoading() {
        let resourceDetails = Manager.resourceNameAndIDFromURL(request.URL!)
        
        switch request.HTTPMethod! {
        case "GET":
            print("GET")
        case "POST":
            if let resourceName = resourceDetails.name, let resource = Manager.resourceByResourceIdentifier(resourceName) {
                let storeKey = request.URL!.relativePath! as String
                
                Manager.registry[resourceName] = [storeKey: resource.data()]
            }
            
        default:
            // TODO: make this throw an error
            print("UNKNOWN")
        }

        let response = NSHTTPURLResponse(URL: request.URL!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: ["Content-Type": "image/jpeg"])!
        
//        let imageData = UIImageJPEGRepresentation(UIImage(named: "nopotatosalad")!, 1.0)!
        let fakeData = NSData()
        
        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        client?.URLProtocol(self, didLoadData: fakeData)
        client?.URLProtocolDidFinishLoading(self)
    }
    
    
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
        for resource in Manager.resources where resource.resourceIdentifier == resourceIdentifier {
            return resource
        }
        
        return nil
    }
}

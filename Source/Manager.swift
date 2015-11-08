//
//  Manager.swift
//  PopTop
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import Foundation
import SwiftyJSON

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
        /// A tuple of (key, id) that will be used within the registry dict based on the URL path
        /// `/path/to/resource/123` -> `("/path/to/resource", 123)`
        let pathToResourceParts = Manager.resourceNameAndIDFromURL(request.URL!)
        
        /// Data that will be returned in the HTTP request.
        var dataToReturn = NSData()
        
        /// The Resource subclass instance itself, if available.
        /// This is used to create new represetnations of a requested resource
        /// requested URL: `/path/to/resource/123` -> resource.data().rawData == {"id": 123, "foo": "bar"}
        let resource = Manager.resourceByResourceIdentifier(pathToResourceParts.name!)
        
        // Bail out if the resource can't be found. This could happen if a resourceIdentifier was not properly set.
        precondition(resource != nil, "Resource not found")
        
        switch request.HTTPMethod! {
        case "GET":
            dataToReturn = GET(resource!, pathToResourceParts: pathToResourceParts)
            
        case "POST":
            dataToReturn = POST(resource!, pathToResourceParts: pathToResourceParts)
            
        case "DELETE":
            DELETE(resource!, pathToResourceParts: pathToResourceParts)
            
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
    
    // MARK: - Instance
    
    func GET(resource: Resource, pathToResourceParts: (name: String?, id: Int?)) -> NSData {
        // If the resource is marked as RESTful (the default) then it is assumed the returned data is JSON from here on out
        if resource.isREST {
            let name = pathToResourceParts.name!
            
            // Check the cache first
            if let collection = Manager.registry[name] {
                // If requesting a particular resource -> "/path/to/resource/123"
                if let id = pathToResourceParts.id, cachedResponse = collection[id] {
                    return cachedResponse
                } else {
                    // There was a request for all available items so build and return a JSON formatted array
                    // There, at this time, isn't an easy way to return this cached array using Swift types so create the return JSON string manually
                    // I'm sad too... :`(
                    var JSONString = "["
                    
                    for (index, object) in collection.enumerate() {
                        JSONString += JSON(data: object.1).rawString()!
                        
                        if index != (collection.count - 1) {
                            JSONString += ","
                        }
                    }
                    
                    JSONString += "]"
                    
                    return JSONString.dataUsingEncoding(NSUTF8StringEncoding)!
                    
                }
            } else {
                // Create the cache for the path name and fill it with NSData representations of the JSON
                Manager.registry[name] = [Int: NSData]()
                let loadedCollection = resource.data().rawData!
                let jsonCollection = JSON(data: loadedCollection)
                
                for (_, subJson) in jsonCollection {
                    let id = Int(subJson["id"].string!)!
                    
                    Manager.registry[name]![id] = try! subJson.rawData()
                }
                
                if let id = pathToResourceParts.id {
                    return Manager.registry[name]![id]!
                } else {
                    return loadedCollection
                }
            }
            
        } else {
            // Designated as a non-REST type so just return the data.
            // This could be an image or even JSON that declines to use PopTop's caching.
            return (resource.data().rawData)!
        }
        
    }
    
    func POST(resource: Resource, pathToResourceParts: (name: String?, id: Int?)) -> NSData {
        let name = pathToResourceParts.name!
        let data = resource.data()
        let id = data.id!
        let dataToReturn = data.rawData!
        
        Manager.registry[name] = [id: dataToReturn]
        
        return dataToReturn
    }
    
    func DELETE(resource: Resource, pathToResourceParts: (name: String?, id: Int?)) {
        let name = pathToResourceParts.name!
        
        if let id = pathToResourceParts.id {
            Manager.registry[name]?.removeValueForKey(id)
        } else{
            Manager.registry[name]?.removeAll()
        }
    }
    
    // MARK: - Helpers
    
    /// Normalize a path which can be used as a Resource Identifier and requested resource ID, if available.
    /// - Returns: "/path/to/resource/123" -> ("/path/to/resource/", 123)
    static func resourceNameAndIDFromURL(url: NSURL) -> (name: String?, id: Int?) {
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
    static func resourceByResourceIdentifier(resourceIdentifier: String) -> Resource? {
        for resource in resources where resource.resourceIdentifier == resourceIdentifier {
            return resource
        }
        
        return nil
    }
}

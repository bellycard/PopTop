//
//  Manager.swift
//  PopTop
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import SwiftyJSON

// Module wide types
public typealias QueryArtifacts = [String: [String]]
public typealias IDArtifacts = [Int]
public typealias NameArtifact = String
public typealias ResourceArtifacts = (ids: IDArtifacts?, query: QueryArtifacts?)

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
        if let requestName = resourceArtifactsFromURL(request.URL!).name, _ = resources[requestName] {
            return true
        }
        
        return false
    }
    
    // MARK: - Instance

    override public func startLoading() {
        /// A tuple of (key, id, query) that will be used within the registry dict based on the URL path
        /// `/path/to/resource/123` -> `(name: "/path/to/resource", ids: [123], query: ["foo": ["bar"]])`
        let resourceArtifacts = Manager.resourceArtifactsFromURL(request.URL!)
        
        /// The Resource itself
        /// This is used to create new represetnations of a requested resource
        let resource = Manager.resources[resourceArtifacts.name!]

        /// Data that will be returned in the HTTP response.
        /// The `name` is not returned as it is identicical to the `resourceIdentifier` on the `resource` instance
        let dataToReturn = resource!.data(request, resourceArtifacts: (ids: resourceArtifacts.ids, query: resourceArtifacts.query))

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

    /// Remove a resource from the manager
    static public func removeResource(resource: ResourceProtocol) {
        resources.remove(resource.resourceIdentifier)
    }

    /// Remove all resources from the manager
    static public func removeResources() {
        resources.removeAll()
    }
    
    // MARK: - Helpers
    
    /// Normalize a path which can be used as a Resource Identifier and requested resource IDs, if available.
    /// - Returns: "/path/to/resource/123?foo=bar&baz=quux" -> ("/path/to/resource/", 123, ["foo": ["bar"], "baz": ["quux"])
    static func resourceArtifactsFromURL(url: NSURL) -> (name: NameArtifact?, ids: IDArtifacts?, query: QueryArtifacts?) {
        guard var pathComponents = url.pathComponents else {
            return (name: nil, ids: nil, query: nil)
        }

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

        let query = queryDictionaryFromURL(url)
        
        return (name, ids, query)
    }

    // inspired by https://gist.github.com/freerunnering/1215df277d750af71887
    /// Return a dictionary with arrays populated with the values of query parameters. URLs allow keys to be declared multiple times, hence the array container.
    static func queryDictionaryFromURL(url: NSURL) -> QueryArtifacts? {
        guard let query = url.query else { return nil }

        var queryDict = [String: [String]]()

        for kVString in query.componentsSeparatedByString("&") {
            let parts = kVString.componentsSeparatedByString("=")

            guard parts.count > 1 else { continue }

            let key = parts.first!.stringByRemovingPercentEncoding!
            let value = parts.last!.stringByRemovingPercentEncoding!
            var values = queryDict[key] ?? [String]()

            if !value.isBlank {
                values.append(value)
                queryDict[key] = values
            }
        }

        return queryDict
    }
}

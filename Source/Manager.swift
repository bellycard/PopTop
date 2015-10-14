//
//  Manager.swift
//  PopTop
//
//  Created by AJ Self on 10/12/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import UIKit

public class Manager: NSURLProtocol {
    // MARK: - Properties
    public static var resources = [String]()
    var connection: NSURLConnection!
    
    // MARK: - Protocol
    // Class
    override public class func canInitWithRequest(request: NSURLRequest) -> Bool {
        guard NSURLProtocol.propertyForKey("PopTopRequestHandled", inRequest: request) == nil else { return false }
        
        if let host = request.URL?.host {
            for resource in resources where resource.containsString(host) {
                return true
            }
        }
        
        return false
    }
    
    // Instance
    override public func startLoading() {
        let newRequest = request.mutableCopy() as! NSMutableURLRequest
        NSURLProtocol.setProperty(true, forKey: "PopTopRequestHandled", inRequest: newRequest)
        connection = NSURLConnection(request: newRequest, delegate: self)
    }
    
    override public func stopLoading() {
        if connection != nil {
            connection.cancel()
        }
        connection = nil
    }
    
    override public class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
}
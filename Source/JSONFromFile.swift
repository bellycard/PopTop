//
//  JSONResource.swift
//  PopTop
//
//  Created by AJ Self on 11/3/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct JSONFromFile: ResourceProtocol {
    public let contentType = "application/json; charset=utf-8"
    let json: JSON
    public let resourceIdentifier: String
    
    public init (resourceIdentifier: String, jsonFileName: String) {
        let file = NSBundle.mainBundle().pathForResource(jsonFileName, ofType: "json")
        self.json = JSON(data: NSData(contentsOfFile: file!)!)
        self.resourceIdentifier = resourceIdentifier
    }

    public func data(request: NSURLRequest) -> NSData {
        return try! json.rawData()
    }
}
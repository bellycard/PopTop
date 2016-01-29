//
//  JSONResource.swift
//  PopTop
//
//  Created by AJ Self on 11/3/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import SwiftyJSON

public class JSONFromFile: ResourceProtocol {
    public let contentType = "application/json; charset=utf-8"
    let jsonFileName: String
    public let resourceIdentifier: String

    lazy var json: JSON = { [unowned self] in
        let file = NSBundle.mainBundle().pathForResource(self.jsonFileName, ofType: "json")
        return JSON(data: NSData(contentsOfFile: file!)!)
    }()
    
    public init (resourceIdentifier: String, jsonFileName: String) {
        self.resourceIdentifier = resourceIdentifier
        self.jsonFileName = jsonFileName
    }

    public func data(request: NSURLRequest, resourceArtifacts: ResourceArtifacts) -> NSData {
        return try! json.rawData()
    }
}
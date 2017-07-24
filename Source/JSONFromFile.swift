//
//  JSONResource.swift
//  PopTop
//
//  Created by AJ Self on 11/3/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import SwiftyJSON

open class JSONFromFile: ResourceProtocol {
    open let contentType = "application/json; charset=utf-8"
    let jsonFileName: String
    open let resourceIdentifier: String

    lazy var json: JSON = { [unowned self] in
        let file = Bundle.main.path(forResource: self.jsonFileName, ofType: "json")
        return JSON(data: NSData(contentsOfFile: file!)! as Data)
    }()
    
    public init (resourceIdentifier: String, jsonFileName: String) {
        self.resourceIdentifier = resourceIdentifier
        self.jsonFileName = jsonFileName
    }

    open func data(_ request: URLRequest, resourceArtifacts: ResourceArtifacts) -> Data {
        return try! json.rawData()
    }
}

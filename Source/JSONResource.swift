//
//  JSONResource.swift
//  PopTop
//
//  Created by AJ Self on 11/3/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import Foundation
import SwiftyJSON

public class JSONResource: Resource {
    
    let json: JSON
    
    public init (resourceIdentifier: String, jsonFileName: String, isREST: Bool = true) {
        let file = NSBundle.mainBundle().pathForResource(jsonFileName, ofType: "json")
        self.json = JSON(data: NSData(contentsOfFile: file!)!)
        
        super.init(resourceIdentifier: resourceIdentifier, contentType: "application/json; charset=utf-8", isREST: isREST)
    }
    
    override public func data() -> (resourceData: NSData?, resourceID: Int?) {
        let returnData = try? json.rawData()
        
        if let returnID = json["id"].string {
            return(returnData, Int(returnID))
        } else {
            return(returnData, nil)
        }
    }
}
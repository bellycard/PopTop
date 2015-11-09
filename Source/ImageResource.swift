//
//  ImageResource.swift
//  PopTop
//
//  Created by AJ Self on 11/5/15.
//  Copyright © 2015 Belly. All rights reserved.
//

import Foundation

public enum ImageType: String {
    case JPEG = "jpg"
    case PNG = "png"
}

public class ImageResource: Resource {
    let imageName: String
    let imageType: ImageType
    let imageRepresentation: NSData?
    
    public init(resourceIdentifier: String, imageName: String, imageType: ImageType) {
        self.imageName = imageName
        self.imageType = imageType
        
        switch imageType {
        case .JPEG:
            self.imageRepresentation = UIImageJPEGRepresentation(UIImage(named: imageName)!, 1.0)
        case .PNG:
            self.imageRepresentation = UIImagePNGRepresentation(UIImage(named: imageName)!)
        }
        
        super.init(resourceIdentifier: resourceIdentifier, contentType: "image/\(imageType)", isREST: false)
    }
    
    override public func data() -> (resourceData: NSData?, resourceID: Int?) {
        return (imageRepresentation, nil)
    }
}
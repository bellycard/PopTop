//
//  ImageResource.swift
//  PopTop
//
//  Created by AJ Self on 11/5/15.
//  Copyright © 2015 Belly. All rights reserved.
//

public enum ImageType: String {
    case JPEG = "jpg"
    case PNG = "png"
}

public struct ImageResource: ResourceProtocol {
    public let contentType: String
    let imageName: String
    let imageType: ImageType
    let imageRepresentation: NSData?
    public let resourceIdentifier: String
    
    public init(resourceIdentifier: String, imageName: String, imageType: ImageType) {
        self.imageName = imageName
        self.imageType = imageType
        
        switch imageType {
        case .JPEG:
            self.imageRepresentation = UIImageJPEGRepresentation(UIImage(named: imageName)!, 1.0)
        case .PNG:
            self.imageRepresentation = UIImagePNGRepresentation(UIImage(named: imageName)!)
        }

        self.contentType = "image/\(imageType)"
        self.resourceIdentifier = resourceIdentifier
    }
    
    public func data(request: NSURLRequest, resourceDetails: (ids: [Int]?, query: [String: [String]]?)) -> NSData {
        return imageRepresentation!
    }
}

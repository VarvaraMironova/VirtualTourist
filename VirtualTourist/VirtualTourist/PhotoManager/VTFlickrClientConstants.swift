//
//  VTFlickrClientConstants.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/27/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

extension VTFlickrClient {
    struct kVTParameters {
        static let baseURL        = "https://api.flickr.com/services/rest/"
        static let methodName     = "flickr.photos.search"
        static let APIKey         = "997631065d8b180112f22052ec0003be"
        static let extras         = "url_m"
        static let dataFormat     = "json"
        static let safeSearch     = "1"
        static let noJSONCallback = "1"
    }
    
    struct kVTKeys {
        static let photo  = "photo"
        static let photos = "photos"
    }
    
}

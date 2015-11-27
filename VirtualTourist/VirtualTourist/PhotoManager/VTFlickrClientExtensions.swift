//
//  VTFlickrClientExtensions.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/27/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation

extension VTFlickrClient {
    
    func searchPhotoNearPin(pin: VTAnnotationModel, completionHandler:(photoArray: [[String: AnyObject]]?, error: NSError?) -> Void) {
        let methodArguments = [
            "method"        : kVTParameters.methodName,
            "api_key"       : kVTParameters.APIKey,
            "bbox"          : pin.searchedCoordinateString(),
            "safe_search"   : kVTParameters.safeSearch,
            "extras"        : kVTParameters.extras,
            "format"        : kVTParameters.dataFormat,
            "nojsoncallback": kVTParameters.noJSONCallback
        ]
        
        let urlString = kVTParameters.baseURL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = self.task(request){data, error in
            if nil != error {
                completionHandler(photoArray: nil, error: error)
            } else {
                VTFlickrClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(photoArray: nil, error: error)
                    } else {
                        if let photosDictionary = result.valueForKey(kVTKeys.photos) as? NSDictionary {
                            if let photoArray = photosDictionary.valueForKey(kVTKeys.photo) as? [[String: AnyObject]] {
                                completionHandler(photoArray: photoArray, error: nil)
                            } else {
                                let contentError = VTFlickrClient.errorForMessage("Can't find key 'photo' in \(photosDictionary)")
                                completionHandler(photoArray: nil, error: contentError)
                            }
                        } else {
                            let contentError = VTFlickrClient.errorForMessage("Can't find key 'photos' in \(result)")
                            completionHandler(photoArray: nil, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func cancel() {
        downloadTask.cancel()
    }
}
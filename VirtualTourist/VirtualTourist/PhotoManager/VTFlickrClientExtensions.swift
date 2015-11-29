//
//  VTFlickrClientExtensions.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/27/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation

extension VTFlickrClient {
    
    func searchPhotoNearPin(pin: VTAnnotationModel, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //check, if pinModel persist in CoreData
        if let pinModel = pin.coreDataModel as VTPinModel! {
            methodArguments["bbox"] = pin.searchedCoordinateString()
            
            let urlString = kVTParameters.baseURL + escapedParameters(methodArguments)
            let url = NSURL(string: urlString)!
            let request = NSURLRequest(URL: url)
            
            downloadTask = self.task(request){data, error in
                if nil != error {
                    completionHandler(success: false, error: error)
                } else {
                    VTFlickrClient.parseJSONWithCompletionHandler(data) {result, error in
                        if nil != error {
                            completionHandler(success: false, error: error)
                        } else {
                            if let photosDictionary = result.valueForKey(kVTKeys.photos) as? NSDictionary {
                                if let pageCount = photosDictionary["pages"] as? Int {
                                    var totalPhotosVal = 0
                                    if let totalPhotos = photosDictionary["total"] as? String {
                                        totalPhotosVal = (totalPhotos as NSString).integerValue
                                    }
                                    
                                    if totalPhotosVal > 0 {
                                        var pageMax:Int = 4000 / Int((self.methodArguments["per_page"])!)!
                                        pageMax = min(pageCount, pageMax)
                                        let randomPage = Int(arc4random_uniform(UInt32(pageMax))) + 1
                                        self.searchPhotosWithPageNumber(randomPage) {images, error in
                                            if nil != error {
                                                completionHandler(success: false, error: error!)
                                            } else {
                                                pinModel.storePhotosFromArray(images!) {finished in
                                                    if finished {
                                                        completionHandler(success: true, error: nil)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    let contentError = VTFlickrClient.errorForMessage("Can't find key 'photo' in \(photosDictionary)")
                                    completionHandler(success: false, error: contentError)
                                }
                            } else {
                                let contentError = VTFlickrClient.errorForMessage("Can't find key 'photos' in \(result)")
                                completionHandler(success: false, error: contentError)
                            }
                        }
                    }
                }
            }
        } else {
            let contentError = VTFlickrClient.errorForMessage("Can't find entity 'pin' \(pin)")
            completionHandler(success: false, error: contentError)
        }
    }
    
    func searchPhotosWithPageNumber(pageNumber: Int, completionHandler:(images: [[String: AnyObject]]?, error: NSError?) -> Void)
    {
        methodArguments["page"] = "\(pageNumber)"
        let urlString = kVTParameters.baseURL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = self.task(request){data, error in
            if nil != error {
                completionHandler(images: nil, error: error)
            } else {
                VTFlickrClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(images: nil, error: error)
                    } else {
                        if let photosDictionary = result.valueForKey(kVTKeys.photos) as? NSDictionary {
                            if let photoArray = photosDictionary.valueForKey(kVTKeys.photo) as? [[String: AnyObject]] {
                                completionHandler(images: photoArray, error: nil)
                            } else {
                                completionHandler(images: nil, error: VTFlickrClient.errorForMessage("Cannot parse JSON"))
                            }
                        } else {
                            completionHandler(images: nil, error: VTFlickrClient.errorForMessage("Cannot parse JSON"))
                        }
                    }
                }
            }
        }
    }
    
    func imageDataForPhotoModel(photoModel: VTPhotoModel, completionHandler:(imageData: NSData?, error: NSError?) -> Void) {
        if let url = NSURL(string: photoModel.url) as NSURL! {
            let request = NSURLRequest(URL: url)
            getImageDataTask = self.taskForImage(request) {result, error in
                if nil == error {
                    completionHandler(imageData: result, error: nil)
                } else {
                    completionHandler(imageData: nil, error: error)
                }
            }
        } else {
            let noURLError = "There is no URL for image"
            completionHandler(imageData: nil, error: VTFlickrClient.errorForMessage(noURLError))
        }
    }
    
    func cancel() {
        if nil != downloadTask {
            downloadTask!.cancel()
        }
    }
}
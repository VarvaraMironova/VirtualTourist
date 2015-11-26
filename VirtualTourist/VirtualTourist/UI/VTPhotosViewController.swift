//
//  VTPhotosViewController.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/24/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit
import MapKit

let kBASE_URL         = "https://api.flickr.com/services/rest/"
let kMETHOD_NAME      = "flickr.photos.search"
let kAPI_KEY          = "997631065d8b180112f22052ec0003be"
let kEXTRAS           = "url_m"
let kDATA_FORMAT      = "json"
let kSafeSearch       = "1"
let kNO_JSON_CALLBACK = "1"

let kBOUNDING_BOX_HALF_WIDTH  = 10.0
let kBOUNDING_BOX_HALF_HEIGHT = 10.0

class VTPhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var selectedPin : VTAnnotationModel!
    var photoArray  : [[String: AnyObject]]!
    var rootView    : VTPhotosView! {
        get {
            if isViewLoaded() && self.view.isKindOfClass(VTPhotosView) {
                return self.view as! VTPhotosView
            } else {
                return nil
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rootView.mapView.addAnnotation(selectedPin)
        
        let methodArguments = [
            "method": kMETHOD_NAME,
            "api_key": kAPI_KEY,
            "bbox": searchedCoordinateString(),
            "safe_search":kSafeSearch,
            "extras":kEXTRAS,
            "format":"json",
            "nojsoncallback": kNO_JSON_CALLBACK
        ]
        
        searchWithArguments(methodArguments)
    }

    @IBAction func onNewCollectionButton(sender: AnyObject) {
        
    }
    
    func mapViewDidStartLoadingMap(mapView: MKMapView) {
        rootView.showLoadingViewInView(rootView.mapView)
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        rootView.hideLoadingView()
    }
    
    func mapViewDidFailLoadingMap(mapView: MKMapView, withError error: NSError) {
        rootView.hideLoadingView()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if nil == photoArray {
            rootView.showNoImagesLabel(true)
            return 0
        } else {
            rootView.showNoImagesLabel(false)
            return photoArray.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VTPhotosCollectionViewCell", forIndexPath: indexPath) as! VTPhotosCollectionViewCell
        cell.fillWithPhotoDictionary(photoArray[indexPath.item])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func searchWithArguments(methodArguments: [String : AnyObject]) {
        let session = NSURLSession.sharedSession()
        let urlString = kBASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
//                var parsingError: NSError? = nil
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                } catch let error as NSError {
                    print(error.localizedDescription)
//                    parsingError = error
                    parsedResult = nil
                } catch {
                    fatalError()
                }
                
                if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                    if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                        if photoArray.count > 15 {
                            self.photoArray = Array(photoArray[0..<15])
                        } else {
                            self.photoArray = photoArray
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.rootView.photosCollectionView.reloadData()
                        })
                    } else {
                        print("Cant find key 'photo' in \(photosDictionary)")
                    }
                } else {
                    print("Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        task.resume()
    }
    
    func searchedCoordinateString() -> String {
        let coordinate = selectedPin.coordinate
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        return "\(longitude - kBOUNDING_BOX_HALF_WIDTH), \(latitude - kBOUNDING_BOX_HALF_HEIGHT), \(longitude + kBOUNDING_BOX_HALF_WIDTH), \(latitude + kBOUNDING_BOX_HALF_HEIGHT)"
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
}

//
//  VTPhotosViewController.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/24/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit
import MapKit

class VTPhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.showLoadingViewInView(rootView.photosCollectionView)
        VTFlickrClient.sharedInstance().searchPhotoNearPin(selectedPin) {photoArray, error in
            dispatch_async(dispatch_get_main_queue(), {
                self.rootView.hideLoadingView()
                if nil != error {
                    self.displayError(error!)
                } else {
                    self.photoArray = photoArray
                    self.rootView.photosCollectionView.reloadData()
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rootView.mapView.addAnnotation(selectedPin)
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
    
    // MARK: - Private
    
    func displayError(error: NSError) {
        self.rootView.hideLoadingView()
            
        let alertViewController: UIAlertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .Alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertViewController, animated: true, completion: nil)
    }
    
}

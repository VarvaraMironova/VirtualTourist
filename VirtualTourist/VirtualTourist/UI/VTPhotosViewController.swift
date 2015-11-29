//
//  VTPhotosViewController.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/24/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VTPhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate
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
    
    // MARK: - Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    // MARK: - Fetched Results Controller
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//        let fetchRequest = NSFetchRequest(entityName: "VTPhotoModel")
//        
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.selectedPin);
//        
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
//            managedObjectContext: self.sharedContext,
//            sectionNameKeyPath: nil,
//            cacheName: nil)
//        
//        return fetchedResultsController
//        
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.mapView.addAnnotation(selectedPin)
        
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
        
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {}
//        
//        fetchedResultsController.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        rootView.mapView.region = MKCoordinateRegionMake(selectedPin.coordinate, MKCoordinateSpanMake(0.04, 0))
    }
    
    @IBAction func onNewCollectionButton(sender: AnyObject) {
        
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

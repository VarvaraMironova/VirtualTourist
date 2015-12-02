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
    var selectedPin     : VTAnnotationModel!
    var blockOperation  : NSBlockOperation?
    var rootView        : VTPhotosView! {
        get {
            if isViewLoaded() && self.view.isKindOfClass(VTPhotosView) {
                return self.view as! VTPhotosView
            } else {
                return nil
            }
        }
    }
    
    var shouldReloadCollectionView : Bool?
    
    // MARK: - Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "VTPhotoModel")
        let pin = self.selectedPin.pin
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin!);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.mapView.addAnnotation(selectedPin)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rootView.mapView.region = MKCoordinateRegionMake(selectedPin.coordinate, MKCoordinateSpanMake(0.04, 0))
    }
    
    @IBAction func onNewCollectionButton(sender: AnyObject) {
        //remove current photoCollection
        if let photos = fetchedResultsController.fetchedObjects as? [VTPhotoModel] {
            dispatch_async(dispatch_get_main_queue()) {
                for photo in photos {
                    CoreDataStackManager.sharedInstance().delete(photo)
                }
            }
        }
        
        //load new photoCollection
        VTFlickrClient.sharedInstance().searchPhotoNearPin(selectedPin.pin!) {success, error in
            if nil != error {
                print(error!.localizedDescription)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.rootView.photosCollectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.fetchedResultsController.sections![section].numberOfObjects
        let needHideLabel = count > 0
        rootView.showNoImagesLabel(needHideLabel)
        
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VTPhotosCollectionViewCell", forIndexPath: indexPath) as! VTPhotosCollectionViewCell
        if fetchedResultsController.fetchedObjects?.count < indexPath.row {
            return cell
        }
        
        let photoModel = fetchedResultsController.objectAtIndexPath(indexPath) as! VTPhotoModel
        var image = UIImage(named: "photoPlaceholder")
        if photoModel.image != nil {
            image = photoModel.image
        } else {
            VTFlickrClient.sharedInstance().imageDataForPhotoModel(photoModel) {data, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let data = data {
                    image = UIImage(data: data)
                    
                    // cash image
                    photoModel.image = image
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.fillWithImage(image!)
                    }
                }
            }
        }

        cell.fillWithImage(image!)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photoModel = fetchedResultsController.objectAtIndexPath(indexPath) as! VTPhotoModel
        CoreDataStackManager.sharedInstance().delete(photoModel)
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    //MARK: - NSFetchedResultControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        shouldReloadCollectionView = false
        blockOperation = NSBlockOperation()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        let collectionView = rootView.photosCollectionView
        switch(type) {
            case .Insert:
                if collectionView.numberOfSections() > 0 {
                    if collectionView.numberOfItemsInSection(newIndexPath!.section) == 0 {
                        self.shouldReloadCollectionView = true;
                    } else {
                        self.blockOperation!.addExecutionBlock({collectionView.insertItemsAtIndexPaths([newIndexPath!])})
                    }
                } else {
                    self.shouldReloadCollectionView = true;
                }
                
                break
                
            case .Delete:
                if collectionView.numberOfItemsInSection(indexPath!.section) == 1 {
                    self.shouldReloadCollectionView = true
                } else {
                    self.blockOperation!.addExecutionBlock({collectionView.deleteItemsAtIndexPaths([indexPath!])})
                }
                
                break
                
            case .Update:
                self.blockOperation!.addExecutionBlock({collectionView.reloadItemsAtIndexPaths([indexPath!])})
                break
                
            case .Move:
                self.blockOperation!.addExecutionBlock({
                    collectionView.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                })
                
                break
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        let collectionView = rootView.photosCollectionView
        switch(type) {
        case .Insert:
            self.blockOperation!.addExecutionBlock({collectionView.insertSections(NSIndexSet(index: sectionIndex))})
            break
            
        case .Delete:
            self.blockOperation!.addExecutionBlock({collectionView.deleteSections(NSIndexSet(index: sectionIndex))})
            break
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if let _ = shouldReloadCollectionView as Bool! {
            rootView.photosCollectionView.reloadData()
        } else {
            rootView.photosCollectionView.performBatchUpdates({self.blockOperation!.start()}, completion: nil)
        }
    }

}

//
//  VTMapViewController.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/24/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit
import MapKit
import CoreData

let kVTDelta         = 0.5
let kVTPinIdentifier = "pin"

class VTMapViewController: UIViewController, MKMapViewDelegate {
    var draggedPin: VTPinModel?
    var settings = VTSettingModel()
    var rootView: VTMapView! {
        get {
            if isViewLoaded() && self.view.isKindOfClass(VTMapView) {
                return self.view as! VTMapView
            } else {
                return nil
            }
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "VTPinModel")
        if let pins = (try? sharedContext.executeFetchRequest(fetchRequest)) as? [VTPinModel] {
            for pin in pins {
                let annotation = VTAnnotationModel(annotation: pin);
                rootView.mapView.addAnnotation(annotation)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let region = settings.region as MKCoordinateRegion? {
            rootView.mapView.setRegion(region, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        settings.region = rootView.mapView.region
    }
    
    @IBAction func onMapTapped(sender: UIGestureRecognizer) {
        let mapView = rootView.mapView
        let point = sender.locationInView(mapView)
        let coordinate = mapView.convertPoint(point, toCoordinateFromView: rootView)
        
        //check if on the map still exists pin with approximately equal (with kVTDelta) coordinates
        for pin in mapView.annotations {
            let pinCoordinate = pin.coordinate
            if fabs(pinCoordinate.latitude - coordinate.latitude) <= kVTDelta &&
                fabs(pinCoordinate.longitude - coordinate.longitude) <= kVTDelta
            {
                return
            }
        }
        
        let annotation = VTAnnotationModel(coordinate: coordinate)
        
        //prefetch photos from Flickr
        VTFlickrClient.sharedInstance().searchPhotoNearPin(annotation) {success, error in
            if nil != error {
                print(error!.localizedDescription)
            } else {
                print("LOADED")
            }
        }
        
        mapView.addAnnotation(annotation)
        
        //save pin to CoreData
        dispatch_async(dispatch_get_main_queue()) {
            let pin = VTPinModel(coordinate: coordinate, context: self.sharedContext)
            annotation.pin = pin
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil;
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(kVTPinIdentifier) as? MKPinAnnotationView
        
        if nil == annotationView {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: kVTPinIdentifier)
            annotationView!.draggable = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //present VTPhotosViewController
        let destinationController = storyboard!.instantiateViewControllerWithIdentifier("VTPhotosViewController") as! VTPhotosViewController
        destinationController.selectedPin = view.annotation as! VTAnnotationModel
        
        navigationController!.pushViewController(destinationController, animated: true)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState)
    {
        if nil == view.annotation {
            return
        }
        
        let coordinate = view.annotation!.coordinate
        
        switch (newState) {
        case .Starting:
            //fetch and save VTPinModel to variable draggedPin
            if let annotationModel = view.annotation as? VTAnnotationModel {
                draggedPin = annotationModel.pinModel()
            }
            
            break
            
        case .Ending:
            //save new coordinate to CoreData
            if nil == self.draggedPin {
                return;
            }
                
            dispatch_async(dispatch_get_main_queue()) {
                self.draggedPin!.coordinate = coordinate
                CoreDataStackManager.sharedInstance().saveContext()
            }
                
            VTFlickrClient.sharedInstance().searchPhotoNearPin(view.annotation as! VTAnnotationModel) {photoArray, error in
                if nil != error {
                    print(error!.localizedDescription)
                } else {
                    print("LOADED")
                }
            }
            
            break
            
        case .Canceling:
            draggedPin = nil
            
            break
            
        default:
            break
        }
    }

}

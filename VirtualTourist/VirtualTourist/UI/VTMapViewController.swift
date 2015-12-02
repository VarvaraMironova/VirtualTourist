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

let kVTDelta         = 0.3
let kVTPinIdentifier = "pin"

class VTMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    var draggedPin: VTAnnotationModel?
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let mapView = rootView.mapView
        
        if let region = settings.region as MKCoordinateRegion? {
            mapView.setRegion(region, animated: true)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            let fetchRequest = NSFetchRequest(entityName: "VTPinModel")
            if let pins = (try? self.sharedContext.executeFetchRequest(fetchRequest)) as? [VTPinModel] {
                for pin in pins {
                    let annotation = VTAnnotationModel(annotation: pin);
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let mapView = rootView.mapView
        settings.region = mapView.region
        
        dispatch_async(dispatch_get_main_queue()) {
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    @IBAction func onMapTapped(sender: UIGestureRecognizer) {
        let mapView = rootView.mapView
        let point = sender.locationInView(mapView)
        let coordinate = mapView.convertPoint(point, toCoordinateFromView: rootView)
        let annotation = VTAnnotationModel(coordinate: coordinate)
        
        switch sender.state {
        case .Began:
            draggedPin = annotation
            mapView.addAnnotation(annotation)
            
            break
            
        case .Changed:
            mapView.removeAnnotation(draggedPin!)
            mapView.addAnnotation(annotation)
            draggedPin = annotation
            
            break
            
        case .Ended:
            //save pin to CoreData
            mapView.removeAnnotation(draggedPin!)
            mapView.addAnnotation(annotation)
            dispatch_async(dispatch_get_main_queue()) {
                let pin = VTPinModel(coordinate: coordinate, context: self.sharedContext)
                annotation.pin = pin
                CoreDataStackManager.sharedInstance().saveContext()
                
                //prefetch photos from Flickr
                VTFlickrClient.sharedInstance().searchPhotoNearPin(pin) {success, error in
                    if nil != error {
                        print(error!.localizedDescription)
                    } else {
                        print("LOADED")
                    }
                }
            }
            
            break
            
        default:
            break
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //present VTPhotosViewController
        let destinationController = storyboard!.instantiateViewControllerWithIdentifier("VTPhotosViewController") as! VTPhotosViewController
        destinationController.selectedPin = view.annotation as! VTAnnotationModel
        
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController!.pushViewController(destinationController, animated: true)
        }
    }
    
}

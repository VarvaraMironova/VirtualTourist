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

let kVTDelta = 0.5

class VTMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
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
        fetchRequest.includesSubentities = false;
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
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
        
        //check if on the map still exists pin with almost equal (with kVTDelta) coordinates
        for pin in mapView.annotations {
            let pinCoordinate = pin.coordinate
            if fabs(pinCoordinate.latitude - coordinate.latitude) <= kVTDelta &&
                fabs(pinCoordinate.longitude - coordinate.longitude) <= kVTDelta
            {
                return
            }
        }
        
        let annotation = VTAnnotationModel(coordinate: coordinate)
        
        mapView.addAnnotation(annotation)
        
        //save pin to CoreData
        dispatch_async(dispatch_get_main_queue()) {
            let pin = VTPinModel(coordinate: coordinate, context: self.sharedContext)
            annotation.pin = pin
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        settings.region = rootView.mapView.region
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //present VTPhotosViewController
        let destinationController = storyboard!.instantiateViewControllerWithIdentifier("VTPhotosViewController") as! VTPhotosViewController
        destinationController.selectedPin = view.annotation as! VTAnnotationModel
        
        navigationController!.pushViewController(destinationController, animated: true)
    }
    
}

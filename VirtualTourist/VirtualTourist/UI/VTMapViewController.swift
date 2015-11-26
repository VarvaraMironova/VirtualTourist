//
//  VTMapViewController.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/24/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit
import MapKit

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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) {
            if touch.view!.isKindOfClass(MKAnnotationView) {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func onMapTapped(sender: UIGestureRecognizer) {
        let mapView = rootView.mapView
        let point = sender.locationInView(mapView)
        let coordinate = mapView.convertPoint(point, toCoordinateFromView: rootView)
        let annotation = VTAnnotationModel(coordinate: coordinate)
        
        mapView.addAnnotation(annotation)
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

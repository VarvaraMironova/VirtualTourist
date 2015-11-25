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
    var rootView: VTMapView! {
        get {
            if isViewLoaded() && self.view.isKindOfClass(VTMapView) {
                return self.view as! VTMapView
            } else {
                return nil
            }
        }
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
    
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        rootView.showLoadingView()
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        rootView.hideLoadingView()
    }
    
    func mapViewDidFailLoadingMap(mapView: MKMapView, withError error: NSError) {
        rootView.hideLoadingView()
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //present VTPhotosViewController
    }

}

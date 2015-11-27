//
//  VTAnnotationModel.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/25/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import MapKit

class VTAnnotationModel: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pin: VTPinModel! {
        didSet {
            coordinate = pin.coordinate
        }
    }

    
    init(annotation: VTPinModel) {
        self.coordinate = annotation.coordinate
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

//
//  VTPinExtensions.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/26/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import MapKit

let kBOUNDING_BOX_HALF_WIDTH  = 5.0
let kBOUNDING_BOX_HALF_HEIGHT = 5.0

extension VTAnnotationModel {
    
    func searchedCoordinateString() -> String {
        let coordinate = self.coordinate
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        return "\(longitude - kBOUNDING_BOX_HALF_WIDTH), \(latitude - kBOUNDING_BOX_HALF_HEIGHT), \(longitude + kBOUNDING_BOX_HALF_WIDTH), \(latitude + kBOUNDING_BOX_HALF_HEIGHT)"
    }
}




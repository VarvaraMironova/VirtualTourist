//
//  VTPhotosView.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/24/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import MapKit
import UIKit

class VTPhotosView: UIView {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var photosCollectionView: UICollectionView!
    @IBOutlet var newCollectionButton: UIButton!
    @IBOutlet var noImagesLabel: UILabel!
    
    func showNoImagesLabel(show: Bool) {
        noImagesLabel.hidden = !show
    }
    
}

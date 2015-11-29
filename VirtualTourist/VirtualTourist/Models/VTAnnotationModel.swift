//
//  VTAnnotationModel.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/25/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import MapKit
import CoreData

class VTAnnotationModel: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var coreDataModel: VTPinModel?
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
    
    
    func pinModel() -> VTPinModel? {
        let fetchRequest = NSFetchRequest(entityName: "VTPinModel")
        let halfDelta = kVTDelta / 2.0
        coreDataModel = nil
        
        fetchRequest.predicate = NSPredicate(format: "latitude > \(coordinate.latitude - halfDelta) AND longitude > \(coordinate.longitude - halfDelta) AND latitude < \(coordinate.latitude + halfDelta) AND longitude < \(coordinate.longitude + halfDelta)");
        
        if let pins = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as? [VTPinModel]
        {
            if pins.count > 0 {
                self.coreDataModel = pins.first!
            }
        }
        
        return coreDataModel
    }
}

//
//  VTPinModel.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/25/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import CoreData
import MapKit

class VTPinModel: NSManagedObject {
    
    struct Keys {
        static let Photos = "photos"
    }
    
    @NSManaged var latitude  : CLLocationDegrees
    @NSManaged var longitude : CLLocationDegrees
    @NSManaged var photos    : [VTPhotoModel]
    
    var coordinate:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set(value) {
            latitude = value.latitude
            longitude = value.longitude
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(coordinate:CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("VTPinModel", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.coordinate = coordinate
    }
    
    func addPhoto(photo:VTPhotoModel) {
        if deleted {
            return
        }
        
        let photos = self.mutableSetValueForKey(Keys.Photos)
        photos.addObject(photo)
        photo.pin = self
    }
}

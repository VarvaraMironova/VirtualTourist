//
//  VTPhotoModel.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/25/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import CoreData
import UIKit

class VTPhotoModel: NSManagedObject {
    
    struct Keys {
        static let Title = "title"
        static let URL   = "url_m"
    }
    
    @NSManaged var pin  : VTPinModel
    @NSManaged var title: String
    @NSManaged var url  : String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("VTPhotoModel", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        url = dictionary[Keys.URL] as! String
        title = dictionary[Keys.Title] as! String
    }

}

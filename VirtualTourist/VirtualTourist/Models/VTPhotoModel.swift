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
    
    lazy var cacheIdentifier: String = {
        return (self.url)
    }()
    
    var image: UIImage? {
        get {
            return VTFlickrClient.Caches.imageCache.imageWithIdentifier(cacheIdentifier)
        }
        
        set {
            VTFlickrClient.Caches.imageCache.storeImage(image, withIdentifier: cacheIdentifier)
        }
    }
    
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
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        // Passing nil will delete the cached file
        VTFlickrClient.Caches.imageCache.storeImage(nil, withIdentifier: self.url)
    }

}

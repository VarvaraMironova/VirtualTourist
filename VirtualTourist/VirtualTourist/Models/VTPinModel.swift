//
//  VTPinModel.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/25/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import CoreData

class VTPinModel: NSManagedObject {
    var latitude    : Float64!
    var longitude   : Float64!
    var photos      : [VTPhotoModel]?
}

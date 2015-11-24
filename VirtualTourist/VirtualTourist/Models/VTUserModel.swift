//
//  VTUserModel.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/25/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import CoreData

class VTUserModel: NSManagedObject {
    var latitude    : Float64!
    var longitude   : Float64!
    var zoomLevel   : Int!
    var pins        : [VTPinModel]?
}

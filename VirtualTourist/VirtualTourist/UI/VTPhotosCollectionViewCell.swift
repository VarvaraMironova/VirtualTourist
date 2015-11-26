//
//  VTPhotosCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/24/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class VTPhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet var photoImageView: UIImageView!
    
    func fillWithPhotoDictionary(photoDictionary:[String: AnyObject]) {
        let imageUrlString = photoDictionary["url_m"] as? String
        let imageURL = NSURL(string: imageUrlString!)
        
        if let imageData = NSData(contentsOfURL: imageURL!) {
            self.photoImageView.image = UIImage(data: imageData)
        } else {
            print("Image does not exist at \(imageURL)")
        }
    }
}

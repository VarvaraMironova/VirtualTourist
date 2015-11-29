//
//  VTUIViewControllerExtensions.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/29/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayError(error: NSError) {
        let alertViewController: UIAlertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .Alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertViewController, animated: true, completion: nil)
    }
}



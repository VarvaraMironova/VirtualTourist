//
//  OTMLoadingView.swift
//  OnTheMap
//
//  Created by Varvara Mironova on 9/30/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class OTMLoadingView: UIView {
    @IBOutlet var spinner: UIActivityIndicatorView!

    weak var rootView: UIView!
    
    class func loadingView (rootView: UIView) -> OTMLoadingView {
        let loadingView = NSBundle.mainBundle().loadNibNamed("OTMLoadingView", owner: self, options: nil).first as! OTMLoadingView

        loadingView.show(rootView)
        
        return loadingView
    }
    
    func show(rootView: UIView) {
        var frame = rootView.frame as CGRect
        frame.origin = CGPointZero;
        self.frame = frame;
        
        rootView.addSubview(self)
        
        self.rootView = rootView
    
        self.spinner.startAnimating();
    }
    
    func hide() {
        if isDescendantOfView(rootView) {
            self.spinner.stopAnimating()
            self.removeFromSuperview()
        }
    }
}

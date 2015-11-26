//
//  OTMView.swift
//  OnTheMap
//
//  Created by Varvara Mironova on 10/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class OTMView: UIView {
    var loadingViewShown : Bool = false
    var loadingView      : OTMLoadingView!
    
    func showLoadingView() {
        showLoadingViewInView(self)
    }
    
    func showLoadingViewInView(view: UIView) {
        if !loadingViewShown {
            loadingView = OTMLoadingView.loadingView(view)
            loadingViewShown = true
        }
    }
    
    func hideLoadingView() {
        if loadingViewShown {
            loadingView.hide()
            loadingView = nil
            loadingViewShown = false
        }
    }

}

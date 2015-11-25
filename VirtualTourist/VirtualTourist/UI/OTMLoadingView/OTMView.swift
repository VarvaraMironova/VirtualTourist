//
//  OTMView.swift
//  OnTheMap
//
//  Created by Varvara Mironova on 10/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class OTMView: UIView {
    
    var loadingView: OTMLoadingView!
    
    func showLoadingView() {
        loadingView = OTMLoadingView.loadingView(self)
    }
    
    func hideLoadingView() {
        loadingView.hide()
        loadingView = nil
    }

}

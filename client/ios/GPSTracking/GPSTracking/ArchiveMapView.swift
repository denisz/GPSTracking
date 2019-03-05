//
//  ArchiveMapView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/8/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class ArchiveMapView: GMSMapView, GMSMapViewDelegate {
    var markerLocation: GMSMarker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMap()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupMap()
    }
    
    func setupMap() {
    }
}
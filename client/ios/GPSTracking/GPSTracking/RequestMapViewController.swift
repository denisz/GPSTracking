//
//  RequestMapViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 5/30/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class RequestMapViewController: UIViewController {
    @IBOutlet weak var mapView: RequestMapView!
    @IBOutlet weak var legend:  UIView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showLegend() {
        self.legend.hidden = false
    }
    
    func hideLegend() {
        self.legend.hidden = true
    }
    
}
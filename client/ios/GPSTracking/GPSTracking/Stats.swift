//
//  Stats.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/15/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


public protocol IStats {
    func create(segmentation: [String: AnyObject])
    func remove(segmentation: [String: AnyObject])
}

public class Stats: NSObject, IStats {
    var key: String?
    
    init(model: Model) {
        self.key = model.formNamed()
    }
    
    public func create(segmentation: [String: AnyObject]) {
        ServerCountly.sharedInstance.event("create.\(key!)", segmentation: segmentation)
    }
    
    public func remove(segmentation: [String: AnyObject]) {
        // ServerCountly.sharedInstance.event(key, prepareSegmentation())
    }
    
    
    class func setLocation(latitude: Double, longitude:Double) {
        ServerCountly.sharedInstance.setLocation(latitude, longitude:longitude)
    }
    
}
//
//  Filter.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/8/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

protocol IFilter {
    func serialize() -> [String: AnyObject]
    func setData(data: [String: AnyObject])
}

class Filter: IFilter {
    var data: [String: AnyObject]
    
    init() {
        self.data = [String: AnyObject]()
    }
    
    func setData(data: [String: AnyObject]) {
        self.data = data
    }
    
    func serialize() -> [String: AnyObject] {
        return self.data
    }

}
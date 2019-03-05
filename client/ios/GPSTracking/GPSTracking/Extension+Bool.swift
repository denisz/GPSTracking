//
//  Extension+Bool.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/14/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

extension Bool {
    init<T : IntegerType>(_ integer: T){
        self.init(integer != 0)
    }
}
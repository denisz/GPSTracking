//
//  Extensions+NSDate.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/2/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }
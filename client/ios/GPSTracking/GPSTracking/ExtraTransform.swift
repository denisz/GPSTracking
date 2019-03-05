//
//  ExtraTranform.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/7/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class ExtraTransform {

    class func Date(value: AnyObject) -> AnyObject {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let date = dateFormatter.dateFromString(value as! String)
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.stringFromDate(date!)
    }
    
    class func StringToDate(value: AnyObject) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return dateFormatter.dateFromString(value as! String)!
    }
    
    class func Time(value: AnyObject) -> AnyObject {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let date = dateFormatter.dateFromString(value as! String)
        
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(date!)
    }
}
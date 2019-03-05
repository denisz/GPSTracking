//
//  NSDate+Extension.swift
//  Tasty
//
//  Created by Vitaliy Kuzmenko on 17/10/14.
//  http://github.com/vitkuzmenko
//  Copyright (c) 2014 Vitaliy Kuz'menko. All rights reserved.
//

import Foundation

let kMinute = 60
let kDay = kMinute * 24
let kWeek = kDay * 7
let kMonth = kDay * 31
let kYear = kDay * 365

func NSDateTimeAgoLocalizedStrings(key: String) -> String {
    
    let resourcePath = NSBundle.mainBundle().resourceURL
    let path = resourcePath?.URLByAppendingPathComponent("NSDateTimeAgo.bundle")
    let bundle = NSBundle(URL: path!)
    
    return NSLocalizedString(key, tableName: "NSDateTimeAgo", bundle: bundle!, comment: "")
}

extension NSDate {
    
    // shows 1 or two letter abbreviation for units.
    // does not include 'ago' text ... just {value}{unit-abbreviation}
    // does not include interim summary options such as 'Just now'
    var timeAgoSimple: String {
        
        let now = NSDate()
        let deltaSeconds = Int(fabs(timeIntervalSinceDate(now)))
        let deltaMinutes = deltaSeconds / 60
        
        var value: Int!
        
        if deltaSeconds < kMinute {
            // Seconds
            return stringFromFormat("%%d%@s", withValue: deltaSeconds)
        } else if deltaMinutes < kMinute {
            // Minutes
            return stringFromFormat("%%d%@m", withValue: deltaMinutes)
        } else if deltaMinutes < kDay {
            // Hours
            value = Int(floor(Float(deltaMinutes / kMinute)))
            return stringFromFormat("%%d%@h", withValue: value)
        } else if deltaMinutes < kWeek {
            // Days
            value = Int(floor(Float(deltaMinutes / kDay)))
            return stringFromFormat("%%d%@d", withValue: value)
        } else if deltaMinutes < kMonth {
            // Weeks
            value = Int(floor(Float(deltaMinutes / kWeek)))
            return stringFromFormat("%%d%@w", withValue: value)
        } else if deltaMinutes < kYear {
            // Month
            value = Int(floor(Float(deltaMinutes / kMonth)))
            return stringFromFormat("%%d%@mo", withValue: value)
        }
        
        // Years
        value = Int(floor(Float(deltaMinutes / kYear)))
        return stringFromFormat("%%d%@yr", withValue: value)
    }

    var timeAgo: String {
        
        let now = NSDate()
        let deltaSeconds = Int(fabs(timeIntervalSinceDate(now)))
        let deltaMinutes = deltaSeconds / 60
        
        var value: Int!
        
        if deltaSeconds < 50 {
            // Just Now
            return NSDateTimeAgoLocalizedStrings("Just now")
        } else if deltaSeconds < 120 {
            // A Minute Ago
            return NSDateTimeAgoLocalizedStrings("A minute ago")
        } else if deltaMinutes < kMinute {
            // Minutes Ago
            return stringFromFormat("%%d %@minutes ago", withValue: deltaMinutes)
        } else if deltaMinutes < 120 {
            // An Hour Ago
            return NSDateTimeAgoLocalizedStrings("An hour ago")
        } else if deltaMinutes < kDay {
            // Hours Ago
            value = Int(floor(Float(deltaMinutes / kMinute)))
            return stringFromFormat("%%d %@hours ago", withValue: value)
        } else if deltaMinutes < (kDay * 2) {
            // Yesterday
            return NSDateTimeAgoLocalizedStrings("Yesterday")
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        return dateFormatter.stringFromDate(self)
    }
    
    func stringFromFormat(format: String, withValue value: Int) -> String {
        
        let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(Double(value)))
        
        return String(format: NSDateTimeAgoLocalizedStrings(localeFormat), value)
    }
    
    func getLocaleFormatUnderscoresWithValue(value: Double) -> String {
        
        let localeCode = NSLocale.preferredLanguages().first
        
        if localeCode == "ru" {
            let XY = Int(floor(value)) % 100
            let Y = Int(floor(value)) % 10
            
            if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
                return ""
            }
            
            if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
                return "_"
            }
            
            if Y == 1 && XY != 11 {
                return "__"
            }
        }
        
        return ""
    }
    
}

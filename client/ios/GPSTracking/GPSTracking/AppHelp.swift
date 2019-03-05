//
//  AppHelp.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/1/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class AppHelp {
    class func callByTelephone(phone: String) {
        if let url = NSURL(string: "tel://\(phone)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    class func sendEmail (email: String) {
        if let url = NSURL(string: "mailto:\(email)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    class func convertDate(value: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        return  dateFormatter.dateFromString(value)!
    }
    
    class func formatDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.doesRelativeDateFormatting = true
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
    
    class func dateNow() -> NSDate {
        return NSDate()
    }
    
    class func getValueByPath(data: [String: AnyObject], forKeyPath path: String) -> [String: AnyObject] {
        let pathSplit = path.componentsSeparatedByString(".")
        return getValueByPath(data, keys: pathSplit)
    }
    
    class func presentAppView() {
        let window = UIApplication.sharedApplication().keyWindow!
        if let controller = window.rootViewController as? StartNavigatonController {
            controller.presentAppView()
        }
    }
    
    class func presentStartup() {
        let window = UIApplication.sharedApplication().keyWindow!
        if let controller = window.rootViewController as? StartNavigatonController {
            controller.presentStartupView()
        }
    }
    
    class func getValueByPath(data: [String: AnyObject], var keys: [String]) -> [String: AnyObject] {
        if keys.count > 0 {
            let key = keys.removeAtIndex(0)
            
            if var obj = data[key] as? [String: AnyObject] {
                obj.updateValue(getValueByPath(obj, keys: keys), forKey: key)
                return obj
            } else {
                var obj = [String: AnyObject]()
                obj.updateValue(getValueByPath(obj, keys: keys), forKey: key)
                return obj
            }
        }
        
        return data;
    }
    
    class func getAddressByCLPlacemark(placemark: CLPlacemark) -> String {
        return "\(placemark.thoroughfare), \(placemark.subThoroughfare), \(placemark.administrativeArea) \(placemark.subAdministrativeArea)"
//        var thoroughfare: String! { get } // street address, eg. 1 Infinite Loop
//        var subThoroughfare: String! { get } // eg. 1
//        var locality: String! { get } // city, eg. Cupertino
//        var subLocality: String! { get } // neighborhood, common name, eg. Mission District
//        var administrativeArea: String! { get } // state, eg. CA
//        var subAdministrativeArea: String! { get } // county, eg. Santa Clara
//        var postalCode: String! { get } // zip code, eg. 95014
//        var ISOcountryCode: String! { get } // eg. US
//        var country: String! { get } // eg. United States
//        
//        return ""
    }
}
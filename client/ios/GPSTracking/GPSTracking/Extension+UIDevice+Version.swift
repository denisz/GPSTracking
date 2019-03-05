//
//  UIDevice+Version.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/26/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

// MARK: - UIDevice Extension
public extension UIDevice {
    
    class func iosVersion() -> Float {
        let versionString =  UIDevice.currentDevice().systemVersion
        return NSString(string: versionString).floatValue
    }
    
    class func isiOS8orLater() ->Bool {
        let version = UIDevice.iosVersion()
        
        if version >= 8.0 {
            return true
        }
        return false
    }
}
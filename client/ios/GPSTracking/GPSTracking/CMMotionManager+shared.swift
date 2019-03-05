//
//  CMMotionManager+shared.swift
//  SnowGlobe
//
//  Created by stringCode on 11/2/14.
//

import UIKit
import CoreMotion

extension CMMotionManager {
    
    public class var sharedInstance: CMMotionManager {
        struct Singleton { static let instance = CMMotionManager() }
        return Singleton.instance
    }
    
    
}
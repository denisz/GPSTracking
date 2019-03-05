//
//  ServerCheckin.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/14/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

let PORT_CHECKIN_SERVER: NSNumber = 3000
let SCHEME_CEHCKIN_SERVER: String = "http"

class ServerCheckin: NSObject {
    var lastCheckin: Checkin?
    var accessToken: AccessToken?
    var _enabled: Bool = false
    var timeInterval: NSTimeInterval = 50.0
    var timer: NSTimer?
    var first: Bool = false

    class var sharedInstance: ServerCheckin {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: ServerCheckin? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = ServerCheckin()
        }
        
        return Static.instance!
    }
    
    func timerDidFire(timer: NSTimer) {
        checkin()
    }
    
    func startTimer() {
        stopTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target:self, selector: "timerDidFire:", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    func enabled() {
        self.startTimer()
        _enabled = true
    }
    
    func disabled() {
        self.stopTimer()
        _enabled = false
    }
    
    func getLocation() -> [String: AnyObject]? {
        if let location = LocationCore.sharedInstance.lastLocation {
            let coordinate  = location.coordinate
            return ["latitude": coordinate.latitude, "longitude": coordinate.longitude]
        }
        
        return nil
    }
    
    func compare(newCheckin: Checkin) -> Bool {
        if (lastCheckin != nil) {
            return lastCheckin!.compareTo(newCheckin)
        }
        
        return false
    }
    
    func hasFirstCheckin() {
        if let lastLocation = LocationCore.sharedInstance.lastLocation {
            let lat = lastLocation.coordinate.latitude as Double
            let lon = lastLocation.coordinate.longitude as Double
            Stats.setLocation(lat, longitude: lon)
        }
    }

    func checkin() {
        if let checkin = getLocation() {
            let checkinModel = Checkin(raw: checkin)
            
            if (!compare(checkinModel)) {
                lastCheckin = checkinModel
                checkinModel.save()
                
                if (!self.first) {
                    self.hasFirstCheckin()
                    self.first = false
                }
            }
        }
    }
    
    func checkin(location: CLLocation) {
        let coordinate  = location.coordinate
        let checkin = ["latitude": coordinate.latitude, "longitude": coordinate.longitude]
        let checkinModel = Checkin(raw: checkin)
        checkinModel.save()
    }
}
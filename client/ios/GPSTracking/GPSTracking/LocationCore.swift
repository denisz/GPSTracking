//
//  LocationCore.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/13/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

class LocationCore {
    var events                  : EventManager
    var lastLocation            : CLLocation?
    var lastLocationLocalized   : String?
    var locationTracker: DLLocationTracker?
    
    class var sharedInstance: LocationCore {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: LocationCore? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationCore()
        }
        
        return Static.instance!
    }
    
    init() {
        self.events = EventManager()
        self.locationTracker = DLLocationTracker()
    }
    
    //получить имя
    func whatIsThisPlace(location: CLLocation, cb: (place: String)-> Void) {
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placesmark, error) -> Void in
            
            if let anError = error {
                print("Reverse geocode fail: \(anError.localizedDescription)")
                return
            }
            
            if let aPlacesmark = placesmark where aPlacesmark.count > 0 {
                
                if let placemark = aPlacesmark.first {
                   cb(place: "\(placemark.name!) \(placemark.locality!) \(placemark.country!)")
                }
            } else {
                
            }
            
        });
    }
    
    func whatIsThisPlace() {
        if let location = self.lastLocation {
            self.whatIsThisPlace(location, cb: {(place: String) in
                self.lastLocationLocalized = place
            })
        }
    }

    //следим за пользователем
    func fullControlWay() {
        self.locationTracker?.locationUpdatedInForeground = {(location) in
            self.lastLocation = location
            self.events.trigger("update")
        }
        
        self.locationTracker?.locationUpdatedInBackground = {(location) in
            self.lastLocation = location
            self.events.trigger("update")
        }
        
        self.locationTracker?.startUpdatingLocation()
    }
}


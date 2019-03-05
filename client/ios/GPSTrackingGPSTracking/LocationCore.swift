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
        events = EventManager()
    }
    
    func WhereAmILocation(action: (lat: CLLocationDegrees, loc: CLLocationDegrees, acc: CLLocationAccuracy)->Void) {
        WhereAmI.whereAmI({ [unowned self] (location) -> Void in
            println(String(format: "lat: %.5f lng: %.5f acc: %2.f", arguments:[location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy]))
            
            self.lastLocation = location
            
            action(lat: location.coordinate.latitude, loc: location.coordinate.longitude, acc: location.horizontalAccuracy)
            
            }, locationRefusedHandler: { [unowned self] () -> Void in
                self.showAlertRefusedView()
            });
        
    }
    
    func WhatIsThisPlace(location: CLLocation, cb: (place: String)-> Void) {
        WhereAmI.whatIsThisPlaceWithLocation(location, geocoderHandler: {(placemark: CLPlacemark!) -> Void in
            if let aPlacemark = placemark {
                println("\(aPlacemark.name) \(aPlacemark.locality) \(aPlacemark.country)")
                cb(place: "\(aPlacemark.name) \(aPlacemark.locality) \(aPlacemark.country)")
            }
        });
        
    }
    
    func WhatIsThisPlace() {
        var location = self.lastLocation!;
        self.WhatIsThisPlace(location, cb: {(place: String) in
                self.lastLocationLocalized = place
        })
    }

    func fullControlWay() {
        
        if (!WhereAmI.userHasBeenPromptedForLocationUse()) {
            
            WhereAmI.sharedInstance.askLocationAuthorization({ [unowned self] (locationIsAuthorized) -> Void in
                if (!locationIsAuthorized) {
                    self.showAlertRefusedView()
                } else {
                    self.startLocationUpdate()
                }
            });
        }
        else if (!WhereAmI.locationIsAuthorized()) {
            self.showAlertRefusedView()
        }
        else {
            self.startLocationUpdate()
        }
    }
    
    private func startLocationUpdate() {
        WhereAmI.sharedInstance.continuousUpdate = true
        WhereAmI.sharedInstance.startUpdatingLocation({ [unowned self]  (location) -> Void in
            self.lastLocation = location
            self.events.trigger("update")
        });
    }
    
    func showAlertRefusedView() {
        //исправить на нормальный диалог с кнопкой настройки
        
        var alertView = UIAlertView(title: "Location Refused",
            message: "The app is not allowed to retreive your current location",
            delegate: nil,
            cancelButtonTitle: "OK")
        
        alertView.show()
    }
    
}


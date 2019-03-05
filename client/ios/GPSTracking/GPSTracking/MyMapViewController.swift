//
//  MyMapViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/26/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import Dollar

let apiKeyGoogleMap = "AIzaSyDPd4vH90mMUE0I9nqycc13ZhaSarecttc"

let KEY_EVENT_USER_LOCATION: String = "currenLocation"

class MyMapViewController : UIViewController, GMSMapViewDelegate {
    
    var mapView: GMSMapView!
    var userMarkerLocation: GMSMarker?
    var userCircleLocation: GMSCircle?
    var firstLocationUpdate: Bool = true
    
    var collection: Collection<Event>?
    var markers: [String: GMSMarker]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSServices.provideAPIKey(apiKeyGoogleMap)
        
        mapView = GMSMapView(frame: CGRectZero)
        mapView.delegate = self
        
        let delta: Int64 = 2 * Int64(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, delta)

        dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
            self.listenLocation()
            self.listenEvents()
            self.updateLocation()
        })
        
        self.markers = [:]
        self.view = mapView
        self.setupCollection()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        let eventId = self.getModelByMarker(marker)
        
        if eventId != nil {
            Dispatcher.sharedInstance.events.trigger(KEY_EVENT_POPUP_EVENT, information: eventId)
        }
        
        return true
    }
    
    func listenEvents() {
        Dispatcher.sharedInstance.events.listenTo(KEY_EVENT_USER_LOCATION, action: animateToUserLocation)
    }
    
    func getModelByMarker(marker: GMSMarker) -> String? {
        for (key, item) in self.markers! {
            if item == marker {
                return key
            }
        }
        
        return nil
    }
    
    override func viewDidAppear(animated: Bool) {
        mapView.padding = UIEdgeInsetsMake (72,0,72,0)
    }
    
    func setupCollection() {
        let user = ServerRestApi.sharedInstance.getUser()
        
        if user != nil {
            collection = user?.collectionNear()
            MapSupport.sharedInstance.initialize(collection!)
            
            collection!.events.listenTo("sync", action: {() in
                $.each(self.collection!.getModels(), callback: self.createMarkerWithEvent)
            })
            
            collection!.events.listenTo("add", action: {(model:Any?) in
                self.createMarkerWithEvent(model as! Event)
            })
            
            collection!.events.listenTo("remove", action: {(model:Any?) in
                self.removeMarkerByEvent(model as! Event)
            })
        }
    }
    
    func updateNearEvents() {
        if self.collection != nil {
            if let location = LocationCore.sharedInstance.lastLocation {
                let currentPosition = location.coordinate
                var data = [String: [String: AnyObject]]()
                
                data["loc"] = [
                    "type"          : "Point",
                    "coordinates"   : [currentPosition.longitude, currentPosition.latitude]
                ]
                
                collection!.setData(data);
                self.collection!.fetch()
            }
        }
    }
    
    func createMarkerWithEvent(model: Event) {
        if self.markers!.indexForKey(model.getIdValue()) == nil {
            let marker = GMSMarker()
            
            marker.icon = GMSMarker.markerImageWithColor(UIColor(red:0.9, green:0.3, blue:0.26, alpha:1))
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.position = model.location().coordinate
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self.mapView
            
            self.markers![model.getIdValue()] = marker
        }
    }
    
    func removeMarkerByEvent(model: Event) {
        let marker = self.markers![model.getIdValue()]
        
        if marker != nil {
            marker?.map = nil
            self.markers!.removeValueForKey(model.getIdValue())
        }
    }
    
    func animateToUserLocation() {
        if let location = LocationCore.sharedInstance.lastLocation {
            let camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 30, viewingAngle: 40)
            let cameraUpdate = GMSCameraUpdate.setCamera(camera)
            self.mapView.animateWithCameraUpdate(cameraUpdate)
        } else {
            let pscope = PermissionsHelper.setupPermissionScrope(self)
            pscope.requestLocationAlways()
        }
    }
    
    func listenLocation() {
        LocationCore.sharedInstance.events.listenTo("update", action: {
            self.updateLocation()
        })
    }
    
    func updateLocation() {
        if let location = LocationCore.sharedInstance.lastLocation {
            if let marker = self.userMarkerLocation {
                marker.position = location.coordinate
            }
            
            if let circle = self.userCircleLocation {
                circle.position = location.coordinate
            }
            
            if self.firstLocationUpdate {
                self.drawPositionUser()
                self.updateNearEvents()
                self.animateToUserLocation()
                self.firstLocationUpdate = false
            }
        }
    }
    
    func drawPositionUser() {
        drawUserCircle()
        drawCircle()
    }
    
    func drawUserCircle() {
        if let location = LocationCore.sharedInstance.lastLocation {
            self.userMarkerLocation = GMSMarker()
            let marker = self.userMarkerLocation!
            
            marker.icon = GMSMarker.markerImageWithColor(UIColor(red:0.09, green:0.34, blue:0.52, alpha:1))
            marker.groundAnchor = CGPoint(x: 0.5, y: 1)
            marker.position = location.coordinate
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self.mapView
        }
    }
    
    func drawCircle() {
        if let location = LocationCore.sharedInstance.lastLocation {
            let circleCenter = location.coordinate
            self.userCircleLocation = GMSCircle(position: circleCenter, radius: 1500)
            
            let circle = self.userCircleLocation!
            circle.strokeColor = UIColor(red:0.27, green:0.54, blue:0.95, alpha:1)
            circle.fillColor = UIColor(red:0.27, green:0.54, blue:0.95, alpha:0.2)
            circle.strokeWidth = 1
            circle.map = mapView;
        }
    }

}
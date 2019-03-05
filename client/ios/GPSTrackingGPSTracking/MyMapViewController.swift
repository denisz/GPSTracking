//
//  MyMapViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/26/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

let apiKeyGoogleMap = "AIzaSyDPd4vH90mMUE0I9nqycc13ZhaSarecttc"


class MyMapViewController : UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var mapView: GMSMapView!
    var userMarkerLocation: GMSMarker?
    var userCircleLocation: GMSCircle?
    var firstLocationUpdate: Bool?
    
    var collection: Collection<Event>?
    var markers: [String: GMSMarker]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSServices.provideAPIKey(apiKeyGoogleMap)
        
        var location = LocationCore.sharedInstance.lastLocation!
        var camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 30, viewingAngle: 40)
        
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.delegate = self
        
        var delta: Int64 = 2 * Int64(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)

        dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
            self.drawPositionUser()
            self.updateNearEvents()
            self.listenLocation()
        })
        
        self.markers = [:]
        self.view = mapView
        
        setupCollection()

        LocationCore.sharedInstance.WhatIsThisPlace()//костыль
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        var eventId = self.getModelByMarker(marker)
        
        if eventId != nil {
            var model = self.collection?.findById(eventId!)
            
            if model != nil {
                var event = model!.copyWithUserAndAnswer()
                Dispatcher.sharedInstance.events.trigger("fastViewAnswer", information: event)
            }
        }
        return true
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
        var user = ServerRestApi.sharedInstance.getUser()
        if user != nil {
            collection = user?.collectionNear()
            
            collection!.events.listenTo("sync", action: {() in
                $.each(self.collection!.getModels(), callback: self.createMarkerWithEvent)
            })
            
            collection!.events.listenTo("add", action: {(model:Any?) in
                self.createMarkerWithEvent(model as! Event)
            })
        }
    }
    
    func updateNearEvents() {
        if self.collection != nil {
            var location = LocationCore.sharedInstance.lastLocation!
            var currentPosition = location.coordinate
            var data = [String: [String: AnyObject]]()
            
            data["loc"] = [
                "type"          : "Point",
                "coordinates"   : [currentPosition.longitude, currentPosition.latitude]
            ]
            
            collection!.setData(data);
            self.collection!.fetch()
        }
    }
    
    func createMarkerWithEvent(model: Event) {
        if self.markers!.indexForKey(model.getIdValue()) == nil {
            var marker = GMSMarker()
            
            marker.icon = GMSMarker.markerImageWithColor(UIColor(red:0.9, green:0.3, blue:0.26, alpha:1))
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.position = model.location().coordinate
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self.mapView
            
            self.markers![model.getIdValue()] = marker
        }
    }
    
    func removeMarkerByEvent(model: Event) {
        var marker = self.markers![model.getIdValue()]
        
        if marker != nil {
            marker?.map = nil
            self.markers!.removeValueForKey(model.getIdValue())
        }
    }
    
    func listenLocation() {
        LocationCore.sharedInstance.events.listenTo("update", action: {
            if let location = LocationCore.sharedInstance.lastLocation {
                if let marker = self.userMarkerLocation {
                    marker.position = location.coordinate
                    self.mapView.animateToLocation(location.coordinate)
                }
                
                if let circle = self.userCircleLocation {
                    circle.position = location.coordinate
                }
            }
        })
        
//        LocationCore.sharedInstance.events.removeListeners("update")
    }
    
    func drawPositionUser() {
        drawUserCircle()
        drawCircle()
    }
    
    func drawUserCircle() {
        var location = LocationCore.sharedInstance.lastLocation!
        self.userMarkerLocation = GMSMarker()
        let marker = self.userMarkerLocation!
        
        marker.icon = GMSMarker.markerImageWithColor(UIColor(red:0.09, green:0.34, blue:0.52, alpha:1))
        marker.groundAnchor = CGPoint(x: 0.5, y: 1)
        marker.position = location.coordinate
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = self.mapView
    }
    
    func drawCircle() {
        var location = LocationCore.sharedInstance.lastLocation!;
        var circleCenter = location.coordinate
        self.userCircleLocation = GMSCircle(position: circleCenter, radius: 300)
        
        let circle = self.userCircleLocation!
        circle.strokeColor = UIColor(red:0.27, green:0.54, blue:0.95, alpha:1)
        circle.fillColor = UIColor(red:0.27, green:0.54, blue:0.95, alpha:0.2)
        circle.strokeWidth = 1
        circle.map = mapView;
    }

}
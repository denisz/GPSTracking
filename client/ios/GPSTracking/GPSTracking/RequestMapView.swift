//
//  MyMapViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/26/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

let contextWithMap: [String] = ["5", "4", "6"]

class RequestMapView : GMSMapView {
    var markerLocation: GMSMarker?
    var parentNavigationController: UINavigationController?
    var model: Event?
    
    var route: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMap()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupMap()
    }
    
    func turnOffUserInteractive() {
    }
    
    func setupMap() {
        markerLocation = GMSMarker()
        self.markerLocation!.map = self
    }
    
    func setLocation(location: CLLocation) {
        camera = GMSCameraPosition(target: location.coordinate, zoom: 16.5, bearing: 30, viewingAngle: 45)
        
        self.markerLocation!.groundAnchor = CGPoint(x: 0.5, y: 1)
        self.markerLocation!.position = location.coordinate
        self.markerLocation!.appearAnimation = kGMSMarkerAnimationPop
    }
    
    func setModel(model: Event) {
        self.model = model
        
        if contextWithMap.contains(model.context!) {
            let from = model.location()
            if let to = model.destinationLocation() {
                setRoute(from, to: to)
            } else {
                setLocation(from)
            }
        } else {
           setLocation(model.location())
        }
    }
    
    func setRoute(from: CLLocation, to: CLLocation) {
        camera = GMSCameraPosition(target: from.coordinate, zoom: 12.5, bearing: 0, viewingAngle: 0)
        
        self.route = true
        
        DirectionMap.fetchDirectionsFrom(from.coordinate, to: to.coordinate) {optionalRoute in
            if let encodedRoute = optionalRoute
            {
                let path = GMSPath(fromEncodedPath: encodedRoute)
                
                let line = GMSPolyline(path: path)
                line.strokeWidth = 2.0
                line.map = self
                line.strokeColor = UIColor(red:0, green:0.64, blue:0.85, alpha:1)
                line.zIndex = 1
                
                if path.count() >= 2 {
                    let from = path.coordinateAtIndex(0)
                    let to = path.coordinateAtIndex(path.count() - 1)
                    self.setupMarker(from, to: to)
                }
            }
        }
    }
    
    func setupMarker(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        let fromMarker = GMSMarker()
        fromMarker.map = self
        fromMarker.icon = GMSMarker.markerImageWithColor(UIColor(red:0.09, green:0.34, blue:0.52, alpha:1))
        fromMarker.groundAnchor = CGPoint(x: 0.5, y: 1)
        fromMarker.position = from
        fromMarker.appearAnimation = kGMSMarkerAnimationPop
        fromMarker.zIndex = 2
        
        let toMarker = GMSMarker()
        toMarker.map = self
        toMarker.icon = GMSMarker.markerImageWithColor(UIColor(red:0.9, green:0.3, blue:0.26, alpha:1))
        toMarker.groundAnchor = CGPoint(x: 0.5, y: 1)
        toMarker.position = to
        toMarker.appearAnimation = kGMSMarkerAnimationPop
        toMarker.zIndex = 3
    }
    
    @IBAction func didTapMap() {
        let mapViewController: RequestMapViewController = UIStoryboard(name: "RequestMapViewController", bundle: nil).instantiateViewControllerWithIdentifier("requestMapView") as! RequestMapViewController
        
        if let nc = self.parentNavigationController {
            nc.pushViewController(mapViewController, animated: true){
                mapViewController.mapView.setModel(self.model!)
                mapViewController.showLegend()
            }
        }
    }
}
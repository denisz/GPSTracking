//
//  ChoicePointInMapViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/17/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import XLForm

class PointInMapViewController: UIViewController, XLFormRowDescriptorViewController, GMSMapViewDelegate {
    
    var mapView         : GMSMapView!
    var rowDescriptor   : XLFormRowDescriptor?
    var markerLocation  : GMSMarker?
    var markerCircle    : GMSCircle?
    
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSServices.provideAPIKey(apiKeyGoogleMap)
        
        var location: CLLocation
        
        if let _location = self.rowDescriptor!.value as? [CLLocationDegrees] {
            location = CLLocation(latitude: _location[0], longitude: _location[1])
        } else {
            location = LocationCore.sharedInstance.lastLocation!
        }
        
        let camera = GMSCameraPosition(target: location.coordinate, zoom: 16.5, bearing: 30, viewingAngle: 40)
        
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.settings.compassButton = false
        mapView.delegate = self
        
        self.view = mapView
        
        configureNavigation()
        
        drawPositionTouch(location.coordinate)
    }
    
    func configureNavigation() {
        self.title = "Карта"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отменить".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapBack")
    }
    
    func didTapKeep() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func didTapBack() {
        self.rowDescriptor!.value = nil
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        drawPositionTouch(coordinate)
    }
    
    func drawPositionTouch(location: CLLocationCoordinate2D) {
        drawUserMarker(location)
        self.rowDescriptor!.value = [location.latitude, location.longitude]
    }
    
    func drawUserMarker(coordinate: CLLocationCoordinate2D) {
        if (self.markerLocation != nil) {
            self.markerLocation!.map = nil
        }
        
        self.markerLocation = GMSMarker()
        self.markerLocation!.icon = GMSMarker.markerImageWithColor(UIColor(red:0.09, green:0.34, blue:0.52, alpha:1))
        self.markerLocation!.groundAnchor = CGPoint(x: 0.5, y: 1)
        self.markerLocation!.position = coordinate
        self.markerLocation!.appearAnimation = kGMSMarkerAnimationPop
        self.markerLocation!.map = self.mapView
    }
}
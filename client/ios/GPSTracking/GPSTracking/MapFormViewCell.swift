//
//  MapFormViewCell.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/28/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

extension MapFormViewCell {
    
    override public func update() {
        super.update()
        
        let mapView = self.getMapView()
        let _value: AnyObject! = self.rowDescriptor!.value
        let isDrawCircle = self.rowDescriptor?.cellOptions.valueForKey("drawCircle") as? Bool

        if _value != nil {
            var value = _value as! [CLLocationDegrees]
            let location = CLLocation(latitude: value[0], longitude: value[1])
            let camera = GMSCameraPosition.cameraWithLatitude(value[0],
                longitude:value[1], zoom:14)
            
            
            drawMarker(location)
            if isDrawCircle != nil {
                drawCircle(location, withRadius: 500)
            }
            
            mapView.camera = camera
        } else {
            self.clearViews()
        }
    }
}
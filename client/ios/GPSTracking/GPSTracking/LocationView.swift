//
//  LocationView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class LocationView: UILabel {
    var iconLayer: CALayer?
    var iconColor: UIColor = UIColor(red:0.62, green:0.65, blue:0.66, alpha:1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconLayer = CALayer()
        iconLayer?.frame = CGRectMake(10.0, 10.0, 14, 21)
        
        changeTintColor(iconColor)
        
        self.layer.addSublayer(iconLayer!)
    }
    
    func createContents(color: UIColor) -> CGImage {
        let rawImage      = UIImage(named: "location2")!
        let iconImage     = rawImage.imageWithColor(color)
        return iconImage.CGImage!
    }
    
    func changeTintColor(color: UIColor) {
        iconLayer?.contents = createContents(color)
    }
    
    override func drawTextInRect(rect: CGRect) {
        let myLabelInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        let newRect = UIEdgeInsetsInsetRect(rect, myLabelInsets)
        super.drawTextInRect(newRect)
    }
}


//
//  LocationButtonView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/30/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class LocationButtonView: UIButton {
    override func drawRect(rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let color = UIColor(red:1, green:1, blue:1, alpha:1)
        let shadowColor2 = UIColor(red: 0.521, green: 0.515, blue: 0.515, alpha: 1.000)
        
        //// Shadow Declarations
        let shadow = shadowColor2
        let shadowOffset = CGSizeMake(0.1, 2.1)
        let shadowBlurRadius: CGFloat = 5
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(roundedRect: CGRectInset(rect, 10, 10), cornerRadius: 30)
        //        var ovalPath = UIBezierPath(ovalInRect: rect)
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, (shadow as UIColor).CGColor)
        color.setFill()
        ovalPath.fill()
        CGContextRestoreGState(context)
    }
    
}
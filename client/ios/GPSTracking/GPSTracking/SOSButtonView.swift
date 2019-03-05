//
//  SOSButton.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit


class SOSButtonView: UIButton {
    override func drawRect(rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let color = UIColor(red:0.9, green:0.3, blue:0.26, alpha:1)
        //UIColor(red: 0.752, green: 0.303, blue: 0.303, alpha: 1.000)
        let shadowColor2 = UIColor(red: 0.521, green: 0.515, blue: 0.515, alpha: 1.000)
        
        //// Shadow Declarations
        let shadow = shadowColor2
        let shadowOffset = CGSizeMake(0.1, 2.1)
        let shadowBlurRadius: CGFloat = 5
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRectInset(rect, 10, 10))
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, (shadow as UIColor).CGColor)
        color.setFill()
        ovalPath.fill()
        CGContextRestoreGState(context)
    }
}
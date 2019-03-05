//
//  GradientUIView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/3/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class GradientUIView: UIView {
    @IBInspectable var color1: UIColor = UIColor(red:1, green:1, blue:1, alpha:0)
    
    @IBInspectable var color2: UIColor = UIColor(red:1, green:1, blue:1, alpha:0.8)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        setupView();
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }
    
    func setupView() {
        let gradient : CAGradientLayer = CAGradientLayer()
        
        // create color array
        let arrayColors: [AnyObject] = [ color1.CGColor, color2.CGColor ]
        
        // set gradient frame bounds to match view bounds
        gradient.frame = self.bounds
        
        // set gradient's color array
        gradient.colors = arrayColors
        
        gradient.locations = [0.4, 1.0]
        
        // replace base layer with gradient layer
        self.layer.insertSublayer(gradient, atIndex: 0)
    }
}
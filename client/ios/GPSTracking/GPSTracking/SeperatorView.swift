//
//  Seperator.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/9/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class SeperatorView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clearColor()
        
        let menuBottomHairline: UIView = UIView()
        
//        menuBottomHairline.setTranslatesAutoresizingMaskIntoConstraints(false)
        menuBottomHairline.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(menuBottomHairline)
        
        let menuBottomHairline_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[menuBottomHairline]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
        let menuBottomHairline_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|[menuBottomHairline(0.5)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
        
        self.addConstraints(menuBottomHairline_constraint_H)
        self.addConstraints(menuBottomHairline_constraint_V)
        
        menuBottomHairline.backgroundColor = self.tintColor
    }

}


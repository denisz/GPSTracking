//
//  AppSosViewButton.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/26/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = borderWidth
        }
           
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(CGColor: layer.borderColor!);
        }
        set {
            layer.borderColor = borderColor.CGColor
        }
    }
}


@IBDesignable
class MyCircleImageView: UIImageView {}

@IBDesignable
class MyCircleButtonView: UIButton {}

@IBDesignable
class MyCircleView: UIView {}
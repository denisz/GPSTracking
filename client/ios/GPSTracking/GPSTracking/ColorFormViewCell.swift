//
//  ColorFormViewCell.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/8/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import XLForm

let XLFormRowDescriptorTypeColor: String = "XLFormRowDescriptorTypeColor";

class ColorFormViewCell: XLFormButtonCell {
    var colorLayer: CALayer?
    
    override func configure() {
        super.configure()
    }
    
    override func update() {
        super.update()
        self.updateColorLayer()
    }
    
    func getColor() -> UIColor {
        if (self.rowDescriptor != nil) {
            if let color: AnyObject = self.rowDescriptor!.value {
                return UIColor(hexString: color as! String)
            }
        }
        
        return UIColor.whiteColor()
    }
    
    func updateColorLayer() {
        if let layer = self.colorLayer {
            layer.backgroundColor = getColor().CGColor
        } else {
            self.createLayer()
        }
    }
    
    func createLayer() {
        self.colorLayer = CALayer()
        let parentRect = self.contentView.frame
        
        self.colorLayer!.cornerRadius = 12
        self.colorLayer!.backgroundColor = getColor().CGColor
        self.colorLayer!.frame = CGRectMake(CGRectGetWidth(parentRect) - 60, 10, 24, 24)
        self.contentView.layer.addSublayer(self.colorLayer!)
    }
}

func RegisterColorFormViewCell() {
    XLFormViewController.cellClassesForRowDescriptorTypes()
        .setObject(ColorFormViewCell.self, forKey: XLFormRowDescriptorTypeColor)
}

//
//  NSString+height.swift
//  Think
//
//  Created by denis zaytcev on 9/1/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation

extension NSString {
    
    func heightText(font: UIFont?, width: CGFloat ) -> CGFloat {
        let attributes = [NSFontAttributeName : font!]
        let rect = self.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return rect.height
    }
}
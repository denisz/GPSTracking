//
//  DetermineHeightRequestInfo.swift
//  GPSTracking
//
//  Created by denis zaytcev on 9/3/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


func DetermineHeightRequestInfo(row: Row) -> CGFloat {
    var height:CGFloat = 44
    
    if row.type == kStaticRowViewDescription {
        var data = row.data
        let value = data["value"] as! String
        height = NSString(string: "\(value)").heightText(kRowDescriptionFont, width: kWidthScreen)
        height += 44
    }
    
    if row.type == kStaticRowViewArray {
        height = 44
    }
    
    if row.type == kStaticRowViewObject {
        var data = row.data
        if let value = data["value"] as? String {
            height = NSString(string: "\(value)").heightText(kRowKeyAndValueFont, width: kWidthScreen / 2)
                    height += 20
        } else {
            height = 44
        }
    }
    
    if row.type == kStaticRowHeader {
        height = 44
    }
    
    if row.type == kStaticRowViewColor {
        height = 56
    }
    
    if let rows = row.subview {
        for row in rows {
            height += row.height
        }
    }
    
    return height
}
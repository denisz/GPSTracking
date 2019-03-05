//
//  StatticRowView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/20/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class StaticRowViewColor: StaticRowView {
    @IBOutlet var keyView: UILabel?
    @IBOutlet var valueView: UIView?
    
    override func prepareView(row: Row) {
        //super.prepareView(row)
        
        var data = row.data
        let key = data["key"] as! String
        let value = data["value"] as! String
        
        keyView!.text = "\(key):"
        valueView!.backgroundColor = ColorHelper.colorWithHexString(value)
    }
}
//
//  StatticRowView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/20/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class StaticRowViewKeyValue: StaticRowView {
    @IBOutlet weak var keyView: UILabel!
    @IBOutlet weak var valueView: UILabel!
    
    override func prepareView(row: Row) {
        //super.prepareView(row)
        
        var data = row.data
        let key = data["key"] as! String
        let value = data["value"] as! String
        
        keyView!.text = "\(key):"
        valueView!.text = value
        valueView!.numberOfLines = 0
        valueView!.sizeToFit()
    }
}
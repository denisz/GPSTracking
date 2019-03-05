//
//  StatticRowView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/20/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class StaticRowViewArray: StaticRowView {
    @IBOutlet var labelView: UILabel?
    
    override func prepareView(row: Row) {
        super.prepareView(row)
        
        var data = row.data
        var label = data["label"] as! String
        
        labelView!.text = label
    }
}
//
//  StatticRowView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/20/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class StaticRowViewDescription: StaticRowView {
    @IBOutlet var keyView: UILabel?
    @IBOutlet var valueView: UITextView?
    
    override func prepareView(row: Row) {
        //super.prepareView(row)
        
        var data = row.data
        let label = data["key"] as! String
        let value = data["value"] as! String
        
        keyView!.text = "\(label):"
        valueView!.text = value
    }
}
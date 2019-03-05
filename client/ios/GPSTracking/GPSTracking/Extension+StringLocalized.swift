//
//  Extension+StringLocalized.swift
//  GPSTracking
//
//  Created by denis zaytcev on 9/20/15.
//  Copyright © 2015 denis zaytcev. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}
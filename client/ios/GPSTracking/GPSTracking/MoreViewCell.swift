//
//  MoreViewCell.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/18/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit


class MoreViewCell: UITableViewCell {
    @IBOutlet weak var activity: UIActivityIndicatorView?
    
    func prepareView(collection: CollectionProtocol) {
        self.separatorInset = UIEdgeInsetsZero
        
        if collection.getStatus() == StatusSync.Syncing {
            startLoading()
        } else {
            endLoading()
        }
    }
    
    func startLoading() {
        activity!.hidden = false
        activity!.startAnimating()
    }
    
    func endLoading() {
        activity?.hidden = true
    }

}
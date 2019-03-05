//
//  StaticRowView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/20/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class StaticRowView: UITableViewCell {
    var row: Row?
    
    @IBOutlet var subview: UIView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func prepareView(data: Row) {
        self.row = data
        setupSubview()
    }
    
    func setupSubview() {
        if let rows = self.row!.subview {
            var tableView = StaticTableView(frame: CGRectZero, style: UITableViewStyle.Plain)
            self.subview!.addSubview(tableView)
            
            let views = ["tableView" : tableView]
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: .AlignAllCenterY, metrics: nil, views: views)
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: .AlignAllCenterX, metrics: nil, views: views)
            
            self.subview!.addConstraints(hConstraints)
            self.subview!.addConstraints(vConstraints)
            
            tableView.setData(rows)
        }
    }
}
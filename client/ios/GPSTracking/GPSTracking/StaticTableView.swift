//
//  StaticTableView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/20/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class Row {
    var data: [String: AnyObject]
    var type: String
    var subview: [Row]?
    
    init(data: [String: AnyObject], subview: [Row]?) {
        self.data = data
        self.type = self.data["type"] as! String
        self.subview = subview
    }
    
    init(data: [String: AnyObject]) {
        self.data = data
        self.type = self.data["type"] as! String
    }
    
    var heightFunc: (row: Row) -> CGFloat = DetermineHeightRequestInfo
    var _height: CGFloat = 0
    var height: CGFloat {
        if _height > 0 {
            return _height
        }
        
        self._height = self.heightFunc(row: self)
        return _height
    }
}

let kStaticRowViewObject: String = "StaticRowViewObject"
let kStaticRowViewArray: String = "StaticRowViewArray"
let kStaticRowViewColor: String = "StaticRowViewColor"
let kStaticRowKeyValue: String = "StaticRowViewKeyValue"
let kStaticRowHeader: String = "StaticRowViewHeader"
let kStaticRowViewDescription: String = "StaticRowViewDescription"

let kWidthScreen: CGFloat = 320
let kRowDescriptionFont = UIFont(name: "HelveticaNeue", size: 15)!
let kRowKeyAndValueFont = UIFont(name: "HelveticaNeue", size: 15)!

let staticRows: [String] = [
      kStaticRowHeader
    , kStaticRowKeyValue
    , kStaticRowViewColor
    , kStaticRowViewObject
    , kStaticRowViewDescription
    , kStaticRowViewArray
]

class StaticTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var cells:[Row]?
    
    init(frame: CGRect) {
        super.init(frame: frame, style: UITableViewStyle.Plain)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup() {
        for rows in staticRows {
            self.registerNib(UINib(nibName: rows, bundle: nil), forCellReuseIdentifier: rows)
        }
        
        self.delegate = self
        self.dataSource = self
        self.scrollEnabled = false
        self.allowsSelection = false
        self.cells = []
        
        if self.respondsToSelector("layoutMargins") {
            self.layoutMargins = UIEdgeInsetsZero
        }
        
        self.separatorInset = UIEdgeInsetsZero
//        self.setTranslatesAutoresizingMaskIntoConstraints(false);
        self.translatesAutoresizingMaskIntoConstraints = false
        self.estimatedRowHeight = 44.0;
        self.rowHeight = UITableViewAutomaticDimension;
    }
    
    func setData(cells: [Row]) {
        self.cells = cells
        self.reloadData()
        self.updateConstraints()
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> Row? {
        return self.cells![indexPath.row];
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = self.objectAtIndexPath(indexPath)!
        let cell: StaticRowView
        
        switch(data.type) {
        case kStaticRowKeyValue:
            cell = tableView.dequeueReusableCellWithIdentifier(kStaticRowKeyValue) as! StaticRowViewKeyValue
            break;
        case kStaticRowHeader:
            cell = tableView.dequeueReusableCellWithIdentifier(kStaticRowHeader) as! StaticRowViewHeader
            break;
        case kStaticRowViewObject:
            cell = tableView.dequeueReusableCellWithIdentifier(kStaticRowViewObject) as! StaticRowViewObject
            break;
        case kStaticRowViewArray:
            cell = tableView.dequeueReusableCellWithIdentifier(kStaticRowViewArray) as! StaticRowViewArray
            break;
        case kStaticRowViewColor:
            cell = tableView.dequeueReusableCellWithIdentifier(kStaticRowViewColor) as! StaticRowViewColor
            break;
        case kStaticRowViewDescription:
            cell = tableView.dequeueReusableCellWithIdentifier(kStaticRowViewDescription) as! StaticRowViewDescription
            break;
        default:
            cell = StaticRowView()
        }
        
        cell.prepareView(data)
        
        if cell.respondsToSelector("layoutMargins") {
            cell.layoutMargins  = UIEdgeInsetsZero
        }
        
        cell.separatorInset = UIEdgeInsetsZero

        if indexPath.row == (self.cells!.count - 1) {
            cell.separatorInset = UIEdgeInsetsMake(0, 2000, 0, 0);
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func intrinsicContentSize() -> CGSize {
        self.layoutIfNeeded()
        //сделать тупо умножение
        return CGSizeMake(UIViewNoIntrinsicMetric, self.contentSize.height);
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let row = self.objectAtIndexPath(indexPath) {
            if row.type == kStaticRowViewDescription {
                return UITableViewAutomaticDimension
            }

            return row.height
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let row = self.objectAtIndexPath(indexPath) {
            return row.height
        }
        
        return UITableViewAutomaticDimension
    }
}
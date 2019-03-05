//
//  AreaFormViewCell.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/1/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import XLForm

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}

let XLFormRowDescriptorTypeArea: String = "XLFormRowDescriptorTypeArea";

class AreaFormViewCell: XLFormTextViewCell {
    override func configure() {
        super.configure()
        self.textView.scrollEnabled = false
    }

    func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor) -> CGFloat{
        return UITableViewAutomaticDimension
    }
    
    func textViewDidChange(textView: UITextView!) {
        let text = self.textView.text

        if text.characters.count > 0 {
            self.rowDescriptor!.value = text;
        } else {
            self.rowDescriptor!.value = nil;
        }
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            if let thisIndexPath = tableView?.indexPathForCell(self) {
                tableView?.scrollToRowAtIndexPath(thisIndexPath, atScrollPosition: .Bottom, animated: false)
            }
        }
    }
}

func RegisterAreaFormViewCell() {
    XLFormViewController.cellClassesForRowDescriptorTypes()
        .setObject(AreaFormViewCell.self, forKey: XLFormRowDescriptorTypeArea)
}

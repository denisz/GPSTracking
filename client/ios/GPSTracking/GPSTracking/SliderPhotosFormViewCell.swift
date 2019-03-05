//
//  SliderPhotoViewCell.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import XLForm

let XLFormRowDescriptorTypeSliderPhotos: String = "XLFormRowDescriptorTypeSliderPhotos";

class SliderPhotosFormViewCell: XLFormBaseCell {
    var sliderView: SliderPhotosView?
    
    override func configure() {
        super.configure()
        self.selectionStyle = UITableViewCellSelectionStyle.None;
    }
    
    override func update() {
        super.update()
        
        if let sv = self.sliderView {
            sv.update()
        } else {
            self.createSliderView()
        }
    }
    
    func createSliderView() {
        if let rowDescriptor = self.rowDescriptor {
            let allowNewPhoto       = rowDescriptor.cellOptions.valueForKey("allowNewPhoto") as! Bool
            let allowRemovePhoto    = rowDescriptor.cellOptions.valueForKey("allowRemovePhoto") as! Bool
            let parentController    = rowDescriptor.cellOptions.valueForKey("parentController") as? UINavigationController
            
            sliderView = SliderPhotosView(frame: self.contentView.frame)
            sliderView!.parentController    = parentController ?? self.formViewController()
            sliderView!.allowNewPhoto       = allowNewPhoto
            sliderView!.allowRemovePhoto    = allowRemovePhoto
            
            let collection: Collection<Attachment> = self.rowDescriptor!.cellOptions.valueForKey("attachments") as! Collection<Attachment>
            sliderView!.loadCollection(collection)
            
            self.contentView.addSubview(sliderView!)
        }
    }
    
    override class func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 160
    }
    
}

func RegisterSliderPhotosFormViewCell() {
    XLFormViewController.cellClassesForRowDescriptorTypes()
        .setObject(SliderPhotosFormViewCell.self, forKey: XLFormRowDescriptorTypeSliderPhotos)
}





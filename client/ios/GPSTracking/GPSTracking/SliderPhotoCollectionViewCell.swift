//
//  SliderPhotoCollectionViewCell.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/1/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import IDMPhotoBrowser

class SliderPhotoCollectionViewCell: UICollectionViewCell, IDMPhotoBrowserDelegate {
    @IBOutlet weak var removeButton: UIButton!
    var allowNewPhoto: Bool = false
    var allowRemovePhoto: Bool = false

    var model: Attachment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didTapRemove() {
        self.model!.remove()?.responseSuccess({ (req, res, JSON, error) -> Void in
            self.model?.removeFromCollection()
        })
    }

    func prepareView(model: Attachment ) {
        self.model = model
        
        let bgView = backgroundView as! UIImageView
        bgView.kf_setImageWithURL(
            model.absoluteUrlThumbB(),
            placeholderImage    : nil,
            options             : KingfisherOptions.None,
            progressBlock       : nil,
            completionHandler   : nil,
            usingProgressView   : nil
        )
        
        removeButton.hidden = !(allowRemovePhoto && self.model!.isOwnerCurrentUser())
    }
    
    func getPhotosByViewer(collection: Collection<Attachment>) ->[IDMPhoto] {
        var photos: [IDMPhoto] = [IDMPhoto]()
        let currentModel = self.model!;
        
        photos.append(IDMPhoto(URL: currentModel.absoluteUrl()))

        collection.each({ (index, model) in
            if model != currentModel {
                let photo: IDMPhoto = IDMPhoto(URL: model.absoluteUrl())
                photos.append(photo)
            }
        })
        
        return photos
    }
    
    func didTapViewCell(controller: UIViewController, collection: Collection<Attachment>) {
        let browser: IDMPhotoBrowser = IDMPhotoBrowser(photos: getPhotosByViewer(collection))
        
        browser.delegate = self
        browser.displayActionButton = false
        browser.displayArrowButton = false
        browser.displayCounterLabel = true
        browser.displayDoneButton = true
        browser.usePopAnimation = false
        browser.useWhiteBackgroundColor = false
        
        controller.presentViewController(browser, animated: true, completion: nil)
    }
}
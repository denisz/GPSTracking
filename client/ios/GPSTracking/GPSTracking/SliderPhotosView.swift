//
//  SliderPhotoViewCollection.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/1/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class SliderPhotosView: UIView {
    var parentController    : UIViewController?
    var collectionView      : SliderPhotosCollectionView?
    var allowNewPhoto       : Bool = false
    var allowRemovePhoto    : Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    func update() {
        if let cv = collectionView {
            cv.reloadData()
        }
    }
    
    func initializeSubviews() {
        collectionView = SliderPhotosCollectionView(nibName: "SliderPhotosCollectionView", bundle: nil)
        collectionView!.allowNewPhoto = allowNewPhoto
        collectionView!.allowRemovePhoto = allowRemovePhoto
        
        self.addSubview(collectionView!.view)
        collectionView!.view.frame = self.bounds
    }
    
    func fetchCollection(collection: Collection<Attachment>) {
        collectionView!.fetchCollection(collection)
        collectionView!.allowNewPhoto = allowNewPhoto
        collectionView!.allowRemovePhoto = allowRemovePhoto
        collectionView!.parentController = self.parentController
    }
    
    func loadCollection(collection: Collection<Attachment>) {
        collectionView!.loadCollection(collection)
        collectionView!.allowNewPhoto = allowNewPhoto
        collectionView!.allowRemovePhoto = allowRemovePhoto
        collectionView!.parentController = self.parentController
    }
    
}
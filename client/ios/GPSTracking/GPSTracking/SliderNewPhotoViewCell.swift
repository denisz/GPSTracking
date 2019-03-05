//
//  SliderNewPhotoViewCell.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class SliderNewPhotoViewCell: UICollectionViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var button: UIButton!
    func prepareView() {}
    
    func didTapViewCell(controller: UIViewController, collection: Collection<Attachment>) {}
}
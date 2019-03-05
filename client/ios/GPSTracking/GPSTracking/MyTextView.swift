//
//  MyTextView.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/23/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class MyTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentInset = UIEdgeInsetsMake(0,0,0,0);
    }
}

//
//  PageContentViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class PageContentViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor(red:0.09, green:0.34, blue:0.52, alpha:1);
        setupKeyboard(true)
    }
}
//
//  EnterPhoneViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit


class EnterPhoneViewController : PageContentViewController {

    @IBOutlet weak var phoneNumber : UITextField?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    @IBAction func phoneNumberHandle() {
        let parentView  = parentViewController as! RootPageViewController;
        _    = phoneNumber!.text;
        parentView.exitToApp()
    }
}

//
//  EnterCodeViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/25/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class EnterCodeViewController : PageContentViewController {
    @IBOutlet weak var codeTextField : UITextField?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
    @IBAction func enterCodeHandle() {
        _ = codeTextField?.text;
        let parentView = self.parentViewController as! RootPageViewController;
        parentView.exitToApp();
    }
}

//
//  InfoViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/9/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class InfoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - UI Setup
        
        self.title = "Информация"
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.09, green:0.34, blue:0.52, alpha:1);
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: UIBarButtonItemStyle.Done, target: self, action: "didTapGoBack")
    }
    
    func didTapGoBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}
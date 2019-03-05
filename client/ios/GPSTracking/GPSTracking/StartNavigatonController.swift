//
//  StartNavigatonViiewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/2/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class StartNavigatonController: UINavigationController {
    override func viewDidLoad() {
        ServerRestApi.sharedInstance.checkActualToken()
            .responseSwiftyJSON({(req, res, json, err) in
                if (err == nil) {
                    if (json["success"] == 1) {
                        self.presentAppView();
                    } else {
                        self.presentStartupView();
                    }
                } else {
                    self.presentStartupView();
                }
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func presentAppView() {
        let radarViewController = UIStoryboard(name: "App", bundle: nil).instantiateViewControllerWithIdentifier("RadarViewController") as! RadarViewController
        radarViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        self.pushViewController(radarViewController, animated: true)
    }
    
    func presentStartupView() {
        let startupViewController = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Startup View Controller") 
        
        self.visibleViewController!.presentViewController(startupViewController, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .LightContent
    }
}
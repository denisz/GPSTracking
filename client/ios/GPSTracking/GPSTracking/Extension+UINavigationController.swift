//
//  ExtensionsUINavigationController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
extension UINavigationController {
    
    func pushViewController(viewController: UIViewController,
        animated: Bool, completion: Void -> Void) {
            
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            pushViewController(viewController, animated: animated)
            CATransaction.commit()
    }
    
}
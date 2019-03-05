//
//  ServerRestApiDelegate.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/22/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import SwiftyJSON

class MyServerRestApiDelegate:ServerRestApiDelegate  {
    func handlerLoginUser(user: User) {
        //отправить статистику
        ServerCountly.sharedInstance.loginUser(user)
//        ServerNotify.sharedInstance.setAccessToken(ServerRestApi.sharedInstance.getAccessToken());
//        ServerNotify.sharedInstance.enabled(
        ServerCheckin.sharedInstance.enabled()
        
        //регистрируем устройство
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let deviceToken = appDelegate.deviceToken {
            ApnHelper.registerDevice(deviceToken)
        }
    }
    
    func handlerLogoutUser(user: User) {
        ServerNotify.sharedInstance.disabled()
        ServerCheckin.sharedInstance.disabled()
    }
    
    func handlerResponseError(err: NSError) {
        
    }
    
    func handlerResponseSuccess(json: JSON) {
        
    }
}
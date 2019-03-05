//
//  PermissionsHelper.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/27/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import PermissionScope

class PermissionsHelper {
    class func setup(cb: ()-> Void) {
        let pscope = PermissionScope(backgroundTapCancels: false)
        
        //доступ к локации
        pscope.addPermission(NotificationsPermission(notificationCategories: nil), message: "Хотели бы вы получать оповещения, когда происходят рядом события?")
        pscope.addPermission(LocationAlwaysPermission(),message:  "Разрешите доступ к своим геоданным, чтобы отмечать свое местоположение")
        
        pscope.headerLabel.text = "Привет!"
        pscope.bodyLabel.text = "Для начала работы нам нужны некоторые права"
        
        pscope.show(
            { (finished, results) -> Void in
                self.checkNotifications()
                
                if  PermissionScope().statusNotifications()  != .Unknown &&
                    PermissionScope().statusLocationAlways() != .Unknown
                {
                    pscope.hide()
                    cb()
                }
            }, cancelled: { (results) -> Void in
                cb()
            })
    }
    
    class func checkNotifications() {
        if PermissionScope().statusNotifications() == .Authorized {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.registerForNotification()
        }
    }
    
    class func requestNotifications() {
        PermissionScope().requestNotifications()
    }
    
    class func requestLocation() {
        PermissionScope().requestLocationAlways()
    }
    
    class func setupPermissionScrope (vc: UIViewController) -> PermissionScope {
        let pscope = PermissionScope(backgroundTapCancels: true)
        pscope.viewControllerForAlerts = vc
        return pscope
    }
    
    class func registerAuthCallback(pscope: PermissionScope, cb: ()-> Void ) {
        pscope.onAuthChange = {(finished: Bool, results: [PermissionResult]) -> Void in
            cb()
        }
    }
    
    class func isAuthNoitification() -> Bool {
        return PermissionScope().statusNotifications() == .Authorized
    }
    
    class func isAuthLocation() -> Bool {
        return PermissionScope().statusLocationAlways() == .Authorized
    }
    
    class func checkLocation(cb: ()-> Void) {
        switch PermissionScope().statusLocationAlways() {
        case  .Unknown:
            self.setup(cb)
            break
        case .Unauthorized, .Disabled:
            cb()
            break
        case .Authorized:
            cb()
            break
        }
    }

}
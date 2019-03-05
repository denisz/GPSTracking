//
//  ServerCountly.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/6/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

let SCHEME_COUNTLY_SERVER: String = "http"
let PORT_COUNTLY_SERVER: NSNumber = 5000
let APP_KEY_COUNTLY_SERVER: String = "ab754b1a67acb02436000629dcebd09193b8dbed"

class ServerCountly: NSObject {
    var countly: Countly;
    
    class var sharedInstance: ServerCountly {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: ServerCountly? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = ServerCountly()
        }
        
        return Static.instance!
    }
    
    override init() {
        self.countly = Countly.sharedInstance()
    }
    
    func urlRequest(url: String) -> String {
        let urlComponents = NSURLComponents()
        urlComponents.port  = PORT_COUNTLY_SERVER
        urlComponents.host  = URL_SERVER
        urlComponents.scheme = SCHEME_COUNTLY_SERVER
        urlComponents.path = url
        
        return urlComponents.string!
    }

    
    func provider(host host: String) {
        self.countly.start(APP_KEY_COUNTLY_SERVER, withHost: host)
    }
    
    func provider() {
        let url = urlRequest("")
        provider(host: url);
    }
    
    func setLocation(latitude: Double, longitude:Double) {
        self.countly.setLocation(latitude, longitude: longitude)
    }
    
    func registerUser(user: User) {
        self.countly.recordUserDetails([
                kCLYUserName: user.valueForKey("fullname") as! String,
                kCLYUserEmail: user.valueForKey("email") as! String,
                kCLYUserUsername: user.valueForKey("fullname") as! String,
                kCLYUserCustom: ["id" : user.getIdValue()]
            ])
    }
    
    func registerForRemoteNotificationTypes(deviceToken: NSData) {
        self.countly.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(error: NSError) {
        self.countly.didFailToRegisterForRemoteNotifications()
    }
    
    func loginUser(user: User) {
    }
    
    //отправляем события
    func event(key: String, segmentation: [NSObject : AnyObject]) {
        self.countly.recordEvent(key, segmentation: segmentation, count: 1)
    }
    
}
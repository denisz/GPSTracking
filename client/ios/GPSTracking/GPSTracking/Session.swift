//
//  Session.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/25/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import SwiftyJSON

class Session: Model {
    override var id_named: String {
        return "session_id"
    }
    
    override func formNamed() -> String {
        return "session"
    }
    
    func updateDeviceToken(device_token: String) {
        self.runAction("apn", data: ["device_token": device_token])
    }
    
    class func withUser() -> Session {
        let session = Session()
        session.link(User(), forKey: "user")
        
        return session
    }
}

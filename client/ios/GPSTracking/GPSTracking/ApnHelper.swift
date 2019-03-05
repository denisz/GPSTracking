class ApnHelper {
    class func registerDevice(deviceToken: NSData) {
        let deviceTokenString = convertDeviceToken(deviceToken)
        
        if ServerRestApi.sharedInstance.signed {
            ServerRestApi.sharedInstance.getSession().updateDeviceToken(deviceTokenString)
        }
        
        ServerCountly.sharedInstance.registerForRemoteNotificationTypes(deviceToken)
    }
    
    class func handleRemoteNotification(userInfo: [NSObject: AnyObject]) {
    
        if let message = userInfo["message"] as? [String: AnyObject]{
            _ = message["command"] as! String
            let data    = message["data"] as! [String: AnyObject]
            let event_id = data["id"] as! String
            
            let handler = {
                Dispatcher.sharedInstance.events.trigger(KEY_EVENT_POPUP_EVENT, information: event_id)
            }

            if !ServerRestApi.sharedInstance.signed {
                Dispatcher.sharedInstance.events.listenTo(KEY_ENTER_APP, action: { () -> () in
                    handler()
                })
            } else {
                handler()
            }
            
        }
    }
    
    class func convertDeviceToken(deviceToken: NSData) -> String {
        let deviceTokenString = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        return deviceTokenString.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
    }
}
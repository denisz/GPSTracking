class ApnHelper {
    static var registered: Bool = false
    
    class func registerDevice(deviceToken: NSData) {
        let deviceTokenString = convertDeviceToken(deviceToken)
        
        if ServerRestApi.sharedInstance.signed && registered == false {
            ServerRestApi.sharedInstance.getSession().updateDeviceToken(deviceTokenString)
            registered = true
        }
    }
    
    class func convertDeviceToken(deviceToken: NSData) -> String {
        var deviceTokenString = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        return deviceTokenString.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
    }
}
//
//  ServerApi.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/25/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import Dollar

#if (arch(i386) || arch(x86_64)) && os(iOS)
let URL_SERVER: String = "lucky.my"
let PORT_SERVER:NSNumber = 3000;
let SCHEME_SERVER:String = "http";
#else
//let URL_SERVER: String = "itwillhelp.ru"
let URL_SERVER: String = "itwillhelp.ru"
let PORT_SERVER:NSNumber = 3000;
let SCHEME_SERVER:String = "http";
#endif


let KEY_USER        : String = "lastUserAccount"
let KEY_ACCESS_TOKEN: String = "X-auth-token"
let ACCOUNT         : String = "myUserAccount"

class RestApiRequest {
    var method      : Alamofire.Method
    var url         : String = ""
    var data        : [String: AnyObject]
    var headers     : [String: String]
    
    init(method: Alamofire.Method, url: String, data: [String: String], headers: [String: String]) {
        self.method     = method
        self.url        = url
        self.data       = data
        self.headers    = headers
    }
    
    init(method: Alamofire.Method, url: String, data: [String: AnyObject], headers: [String: String]) {
        self.method     = method
        self.url        = url
        self.data       = data
        self.headers    = headers
    }
    
    func urlRequest() -> String {
        let urlComponents = NSURLComponents()
        urlComponents.port  = PORT_SERVER
        urlComponents.host = URL_SERVER
        urlComponents.scheme = SCHEME_SERVER
        urlComponents.path = url
        
        return urlComponents.string!
    }
    
    func setData(data: [String: String]) {
        for (key, value) in data {
            self.data[key] = value;
        }
    }
    
    func request() -> NSMutableURLRequest{
        let URL = NSURL(string: urlRequest())!;
        let mutableURLRequest = NSMutableURLRequest(URL: URL);
        mutableURLRequest.HTTPMethod = method.rawValue;
        
        for (field, value) in headers {
            mutableURLRequest.setValue(value, forHTTPHeaderField: field);
        }
        
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }catch {}
        
        return mutableURLRequest;
    }
    
    func uploadImageRequest() -> (URLRequestConvertible, NSData) {
        let parameters = $.omit(self.data, keys: "image")
        let image: UIImage = self.data["image"] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 1)
        
        return urlRequestWithComponents(urlRequest(), parameters: parameters, imageData: imageData!)
    }
    
    func uploadFileRequest() {
        
    }
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    func urlRequestWithComponents(urlString:String, parameters:[String: AnyObject], imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        
        for (field, value) in headers {
            mutableURLRequest.setValue(value, forHTTPHeaderField: field);
        }
        
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    func useAccessToken(access_token : AccessToken) {
        headers[KEY_ACCESS_TOKEN] = access_token.get();
    }
}

protocol ServerRestApiDelegate {
    func handlerLoginUser(user: User)
    func handlerLogoutUser(user: User)
    func handlerResponseError(err: NSError)
    func handlerResponseSuccess(json: JSON)
}

class ServerRestApi {
    var requestManager  : Alamofire.Manager?
    var access_token    : AccessToken?
    var session         : Session?
    var delegate        : ServerRestApiDelegate = MyServerRestApiDelegate()
    var signed          : Bool = false
    
    class var sharedInstance: ServerRestApi {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: ServerRestApi? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = ServerRestApi()
        }
        
        return Static.instance!
    }
    
    init() {
        access_token = AccessToken()
        prepareSession()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey(KEY_USER) {
            access_token!.tryLoadAccessToken(name)
        }
        
        setup()
    }
    
    func prepareSession() {
        self.session = Session.withUser()
        let user = session!.getLink("user") as? User
        user!.events.listenTo("sync", action: {
            self.keepLastUserNamed(user!.email)
            user!.events.removeListeners("sync")
        })

        session!.events.listenTo("sync", action: {
            self.signed = true
            let user = self.getUser()!
            self.access_token!.set(self.session!.getIdValue(), accountNamed: user.email)
            self.delegate.handlerLoginUser(user);
            self.session!.events.removeListeners("sync")
        })
    }
    
    func getSession() -> Session {
        return self.session!
    }
    
    func getAccessToken() -> AccessToken? {
        return self.access_token
    }
    
    func setup() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 20
        
        self.requestManager = Alamofire.Manager(configuration: config)
    }
    
    func getUser() -> User? {
        return self.session?.getLink("user") as? User
    }
    
    func logout () {
        self.signed = false
        let user = getUser()
        self.access_token!.drop()
        self.prepareSession()
        self.delegate.handlerLogoutUser(user!)
    }
    
    func handleSuccess(json: SwiftyJSON.JSON) {
        if session!.hasFormData(json) {
            session!.performSync(json)
        }
        self.delegate.handlerResponseSuccess(json)
    }
    
    func handleError(err: NSError) {
        self.delegate.handlerResponseError(err);
    }
    
    func handleResponse(req: NSURLRequest, res: NSHTTPURLResponse?, json: JSON, err: NSError?) {
        if (err == nil) {
            self.handleSuccess(json)
        } else {
            self.handleError(err!)
        }
    }
    
    func sendRequest(requestManager: Alamofire.Manager, request: RestApiRequest)-> Alamofire.Request {
        request.useAccessToken(access_token!)
        
        return requestManager.request(request.request())
            .debugLog()
            .responseSwiftyJSON(self.handleResponse);
    }

    func sendRequest(request: RestApiRequest)-> Alamofire.Request {
        request.useAccessToken(access_token!)
        
        return requestManager!.request(request.request())
            .debugLog()
            .responseSwiftyJSON(self.handleResponse);
    }
    
    func uploadImage(request: RestApiRequest) -> Request {
        request.useAccessToken(access_token!)
        
        let urlRequest = request.uploadImageRequest()
        return Alamofire.upload(urlRequest.0, data: urlRequest.1).debugLog()
    }
    
    func uploadFile(request: RestApiRequest) -> Request {
        request.useAccessToken(access_token!)
        
        let urlRequest = request.uploadImageRequest()
        return Alamofire.upload(urlRequest.0, data: urlRequest.1).debugLog()
    }
    
    func keepLastUserNamed(email: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(email, forKey: KEY_USER)
    }
    
    func checkActualToken () -> Request {
        return sendRequest(API.checkToken())
            .responseSwiftyJSON({(req, res, json, err) in
                if (err == nil) {
                    if (json["success"] == 0) {
                        self.access_token!.drop()
                    }
                } else {
                    self.access_token!.drop()
                }
            })
    }
}

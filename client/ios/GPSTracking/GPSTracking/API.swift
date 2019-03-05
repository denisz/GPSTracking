//
//  API.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/25/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import Alamofire

class API {
    class func login(email: String, password: String) -> RestApiRequest {
        let data = ["email" : email, "password" : password];
        return RestApiRequest(method: Alamofire.Method.POST, url: "/account/login", data: data, headers: [:]);
    }
    
    class func loginFB(access_token: String) -> RestApiRequest {
        let data = ["access_token" : access_token];
        return RestApiRequest(method: Alamofire.Method.POST, url: "/account/login/social/fb", data: data, headers: [:]);
    }
    
    class func uploadImage(data: [String : AnyObject]) -> RestApiRequest {
        return RestApiRequest(method: Alamofire.Method.POST, url: "/upload/image", data: data, headers: [:]);
    }

    class func uploadFile(data: [String : AnyObject]) -> RestApiRequest {
        return RestApiRequest(method: Alamofire.Method.POST, url: "/upload/file", data: data, headers: [:]);
    }

    //заменить на create
    class func register(data: [String : String]) -> RestApiRequest {
        return RestApiRequest(method: Alamofire.Method.POST, url: "/account/register", data: data, headers: [:]);
    }
    
    class func checkToken() -> RestApiRequest {
        return RestApiRequest(method: Alamofire.Method.POST, url: "/auth/whoisiam", data: [:], headers: [:]);
    }
    
    class func list(form: String, destination: String) -> (data: [String: AnyObject]) -> RestApiRequest {
        let request = {(data: [String: AnyObject])->RestApiRequest in
            return RestApiRequest(method: Alamofire.Method.POST, url: "/\(form)/list/\(destination)", data: data, headers: [:])
        }
        
        return request;
    }
    
    class func logout () -> RestApiRequest {
        return RestApiRequest(method: Alamofire.Method.POST, url: "/auth/logout", data: [:], headers: [:]);
    }
    
    class func crud(form: String) -> [String: (data: [String: AnyObject]) -> RestApiRequest] {
        
        let request: [String: (data: [String: AnyObject]) -> RestApiRequest] =
        [
            "create" :{(data: [String: AnyObject]) -> RestApiRequest  in
                    return RestApiRequest(method: Alamofire.Method.POST, url: "/\(form)/create", data: data, headers: [:])
                },
            "update": {(data: [String: AnyObject]) -> RestApiRequest  in
                    return RestApiRequest(method: Alamofire.Method.PUT, url: "/\(form)/update", data: data, headers: [:])
                },
            "delete" :{(data: [String: AnyObject]) -> RestApiRequest  in
                    return RestApiRequest(method: Alamofire.Method.DELETE, url: "/\(form)/delete", data: data, headers: [:])
                },
            "get" : {(data: [String: AnyObject]) -> RestApiRequest  in
                    return RestApiRequest(method: Alamofire.Method.POST, url: "/\(form)/get", data: data, headers: [:])
                }
        ]
        
        return request
    }
    
    class func method(form: String, method: String) -> (data: [String: AnyObject]) -> RestApiRequest {
        return {(data: [String: AnyObject]) -> RestApiRequest  in
            RestApiRequest(method: Alamofire.Method.POST, url: "/\(form)/\(method)", data: data, headers: [:])
        }
    }
}
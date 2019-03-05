//
//  AlamofireSwiftyJSON.swift
//  AlamofireSwiftyJSON
//
//  Created by Pinglin Tang on 14-9-22.
//  Copyright (c) 2014 SwiftyJSON. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

// MARK: - Request for Swift JSON
extension Request {
    public func debugLog() -> Self {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            debugPrint(self)
        #endif
        return self
    }
}

extension Request {
    
    public func responseSuccess(completionHandler: (NSURLRequest, NSHTTPURLResponse?, SwiftyJSON.JSON, NSError?) -> Void) -> Self {
        return responseSuccess(nil, options:NSJSONReadingOptions.AllowFragments, completionHandler:completionHandler)
    }
    
    public func responseSuccess(queue: dispatch_queue_t? = nil, options: NSJSONReadingOptions = .AllowFragments, completionHandler: (NSURLRequest, NSHTTPURLResponse?, JSON, NSError?) -> Void) -> Self {
        
        return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: options)) { (req, res, result) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                if result.isSuccess {
                    var responseJSON = SwiftyJSON.JSON(result.value!)
                    
                    if responseJSON["success"].number == 1 {
                        dispatch_async(queue ?? dispatch_get_main_queue(), {
                            completionHandler(req!, res, responseJSON, nil)
                        })
                    }
                    
                }
            })
        }
    }
    
    public func responseFailed(completionHandler: (NSURLRequest, NSHTTPURLResponse?, SwiftyJSON.JSON, NSError?) -> Void) -> Self {
        return responseFailed(nil, options:NSJSONReadingOptions.AllowFragments, completionHandler:completionHandler)
    }
    
    public func responseFailed(queue: dispatch_queue_t? = nil, options: NSJSONReadingOptions = .AllowFragments, completionHandler: (NSURLRequest, NSHTTPURLResponse?, JSON, NSError?) -> Void) -> Self {
        
        return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: options), completionHandler: { (req, res, result) -> Void in
            
            if result.isSuccess {
                var responseJSON = SwiftyJSON.JSON(result.value!)
                
                if responseJSON["success"].number == 0 {
                    dispatch_async(queue ?? dispatch_get_main_queue(), {
                        completionHandler(req!, res, responseJSON, nil)
                    })
                }
            }
        })
    }
}

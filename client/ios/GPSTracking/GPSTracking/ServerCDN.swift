//
//  ServerCDN.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class ServerCDN {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
    let server_url: String = "http://lucky.my:3000/static/"
    #else
    let server_url: String = "http://85.143.218.133:3000/static/"
//    let server_url: String = "http://107.170.13.31:3000/static/"
    #endif
    
    class var sharedInstance: ServerCDN {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: ServerCDN? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = ServerCDN()
        }
        
        return Static.instance!
    }
    
    init() {
        
    }
    
    func getStringUrl() -> String {
        return server_url
    }
    
    func absolutePath(path: String) -> NSURL {
        return NSURL(string: "\(server_url)\(path)")!
    }
}
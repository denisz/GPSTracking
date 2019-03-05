//
//  Dispatcher.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/22/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class Dispatcher {
    var events: EventManager = EventManager()
    
    class var sharedInstance: Dispatcher {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Dispatcher? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = Dispatcher()
        }
        
        return Static.instance!
    }
    
    init() {
    }
}
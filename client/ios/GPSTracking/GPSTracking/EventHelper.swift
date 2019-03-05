//
//  EventParams.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/10/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import SwiftyJSON

class EventHelper {
    class func context()-> [[String:AnyObject]] {
        return EventContext
    }
    
    class func subtypes()-> [[String:AnyObject]] {
        return EventSubtypes
    }
    
    class func extra() ->  EventExtraParams {
        return EventExtra
    }
    
    class func fields() -> [String: [String: AnyObject]] {
        return ExtraFields
    }
    
    class func contextByArray(ids: [String]) -> [[String:AnyObject]]{
        var result = [[String:AnyObject]]()
        
        for id in ids {
            if let context = contextByValue(id) {
                result.append(context)
            }
        }
        
        return result
    }
    
    class func contextByValue(value: String) -> [String:AnyObject]? {
        let types = EventHelper.context()
        
        for type in types {
            let val = type["value"] as! String;
            if val == value {
                return type
            }
        }
        
        return nil
    }
    
    class func subtypeByValue(value: String) -> [String:AnyObject]? {
        let subtypes = EventHelper.subtypes()
        
        for type in subtypes {
            let val = type["value"] as! String;
            if val == value {
                return type
            }
        }
        
        return nil
    }
    
    class func extraByValue(value: String) -> [String]? {
        var extra = EventHelper.extra()
        
        return extra[value]
    }
    
    class func subtypesByType(value: String) -> [[String:AnyObject]]? {
        var type = EventHelper.contextByValue(value)
        var result: [[String:AnyObject]] = [];
        
        if (type != nil) {
            let subtype = type!["subtype"] as? [String]
            
            if subtype != nil {
                for value in subtype! {
                    if let data = EventHelper.subtypeByValue(value) {
                        result.append(data);
                    }
                }
            }
        }
        
        return result
    }
    
    class func setupViewByFields(field: String) -> [String: AnyObject]? {
        let fields = self.fields()
        return fields[field]
    }
    
    class func findDependencies(findDep: String) -> [String] {
        var result: [String] = []
        let fields = self.fields()
        
        for (field, options) in fields {
            if let depField = options["dependenciesField"] as? String {
                if depField == findDep {
                    result.append(field)
                }
            }
        }
        
        return result
    }
}
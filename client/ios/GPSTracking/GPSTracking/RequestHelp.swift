//
//  DescriptionRequestHelp.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

class RequestHelp {
    class func parseDescription(model: Event) -> [Row] {
        let context     = model.context
        let subtype     = model.subtype
        
        if let extra = model.extraCriteria {
            if let fields = findFieldsForExtra(context!, subtype: subtype) {
                return parseFields(fields, extra: extra)!
            }
        }
        
        return []
    }
    
    class func parseFields(fields: [String], extra: [String: AnyObject]?) -> [Row]? {
        if let objFields = extra {
            var result: [Row] = []
            
            for (fieldNamed) in fields {
                if let value: AnyObject = objFields[fieldNamed] {
                    let properties: [String: AnyObject] = propertiesField(fieldNamed)!
                    let format = CommonFormViewControllerFormat(rawValue: properties["format"] as! Int)
                    
                    switch(format!) {
                    case .Single:
                        if let row = parseView(properties, value: value){
                            result.append(row)
                        }
                        break;
                    case .Multi:
                        if let arrayItem = value as? [String: AnyObject] {
                            var resultArray: [Row] = []
                            for (_, item) in arrayItem {
                                if let row = parseView(properties, value: item){
                                    resultArray.append(row)
                                }
                            }
                            let row = Row(data: [
                                "type" : kStaticRowHeader,
                                "label": properties["title"] as! String
                                ], subview: resultArray)
                            
                            result.append(row)
                        }
                        break;
                    case .Seperator:
                        break;
                    }
                }
            }
            return result
        }
        
        return nil
    }
    
    class func parseView(properties: [String: AnyObject], value: AnyObject) -> Row? {
        if let type = properties["view"] as? String {
            switch(type) {
            case kStaticRowKeyValue:
                return Row(data: [
                    "type"      : kStaticRowKeyValue,
                    "key"       : properties["title"] as! String,
                    "value"     : transformValue(value, setup: properties)
                    ])
            case kStaticRowViewObject:
                return Row(data: [
                    "type"      : kStaticRowViewObject,
                    "label"     : properties["title"] as! String
                    ], subview: parseFields(properties["fields"] as! [String], extra: value as? [String: AnyObject]))
            case kStaticRowViewColor:
                return Row(data: [
                    "type"      : kStaticRowViewColor,
                    "key"       : properties["title"] as! String,
                    "value"     : value
                    ])
            case kStaticRowViewDescription:
                return Row(data: [
                    "type"      : kStaticRowViewDescription,
                    "key"       : properties["title"] as! String,
                    "value"     : value
                    ])
            case kStaticRowViewArray:
                return Row(data: [
                    "type"      : kStaticRowViewArray,
                    "label"     : properties["titleRow"] as! String
                    ], subview: parseFields(properties["fields"] as! [String], extra: value as? [String: AnyObject]))
            default:
                return nil;
            }
        }
        
        return nil
    }
    
    class func propertiesField(fieldNamed: String) -> [String: AnyObject]? {
        return EventHelper.setupViewByFields(fieldNamed);
    }
    
    class func findFieldsForExtra(context: String, subtype: String?) -> [String]? {
        let contextProperties = EventHelper.contextByValue(context)!
        if let _ = contextProperties["extra"] as? Bool {
            return EventHelper.extraByValue(contextProperties["extraFields"] as! String)
        }
        
        if let subtypeValue = subtype {
            let subtypeProperties = EventHelper.subtypeByValue(subtypeValue)!
            if let _ = subtypeProperties["extra"] as? Bool {
                return EventHelper.extraByValue(subtypeProperties["extraFields"] as! String)
            }
        }
        
        return nil
    }
    
    class func transformValue(value: AnyObject, setup: [String: AnyObject]) -> String {
        if setup["transform"] != nil {
            if let action = getTransformFunction(setup["transform"] as! String) {
                return  action(value: value) as! String
            }
        }
        
        return "\(value)"
    }
    
    class func getTransformFunction(named: String) -> ((value: AnyObject) -> AnyObject)? {
        switch named {
        case "Date":
            return ExtraTransform.Date;
        case "Time":
            return ExtraTransform.Time;
        case "StringToDate":
            return ExtraTransform.StringToDate;
        default:
            return nil
        }
    }
}
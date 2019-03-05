//
//  CategoryAuto.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/8/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//
func CategoryAutoData() -> [String: AnyObject] {
    let path = NSBundle.mainBundle().pathForResource("categoryAuto", ofType: "json")
    
    
    let jsonData = NSData(contentsOfFile: path!)
    var result:[String: AnyObject] = [:]
    
    do{
        result = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions()) as! [String : AnyObject]
    }catch{
        print(error)
    }
    
    return result
}
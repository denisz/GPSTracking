//
//  DirectionMap.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/22/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class DirectionMap {
    static var session: NSURLSession {
        return NSURLSession.sharedSession()
    }

    class func fetchDirectionsFrom(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: ((String?) -> Void)) -> ()
    {
        let rUrl1 = "http://maps.googleapis.com/maps/api/directions/json?origin="+String(format:"%f", from.latitude)+","+String(format:"%f", from.longitude)
        let rUrl2 = "&destination="+String(format:"%f", to.latitude)+","+String(format:"%f", to.longitude)+"&sensor=false&mode=walking&units=metric" //+key="\(apiKeyGoogleMap)"
        
        let urlString = rUrl1+rUrl2
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let url = NSURL(string: urlString)!
        session.dataTaskWithURL(url) { (data, res, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var encodedRoute: String?
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]
                
                if let routes = json["routes"] as AnyObject? as? [AnyObject] {
                    
                    
                    if let route = routes.first as? [String : AnyObject] {
                        if let legs = route["legs"] as? [AnyObject] {
                            if let _ = legs.first as? [String: AnyObject] {
                                
                            }
                        }
                        if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
                            if let points = polyline["points"] as AnyObject? as? String {
                                encodedRoute = points
                            }
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(encodedRoute)
                }
                
            }catch {}
            
        }.resume()
    }
}
//
//  Model.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum StatusSync {
    case  Syncing, Removed, Created, Synced, Error
}

public protocol RecordStatsDelegate {
    func stats(shouldRecordEventByModel model: Model ) -> Bool
    func stats(segmentationForEventByModel model: Model ) -> [String: AnyObject]
    func stats(objectStatsByModel model: Model )-> IStats
}

public class Model: ModelProtocol, Printable, Equatable, RecordStatsDelegate {
    var data        : [String: AnyObject]
    var events      : EventManager
    var id_named    : String {
        return "_id"
    }
    var api         : [String: (data: [String: AnyObject]) -> RestApiRequest]?
    var status      : StatusSync = .Created
    var error       : NSError?
    var links       : [String: AnyObject]?
    var _created_at : NSDate?
    
    var id: String {
        return idValue(id_named)
    }
    
    func getIdValue()->String {
        return idValue(id_named);
    }
    
    func isSync() -> Bool {
        return self.status == StatusSync.Synced && !self.id.isEmpty
    }
    
    func getObjectIdValue() ->String {
        return valueForKey("object_id") as! String
    }
    
    func getCreatedAt() -> NSDate {
        if _created_at == nil {
            var rawDate     = valueForKey("created_at") as! String
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
            let date = dateFormatter.dateFromString(rawDate)
            self._created_at = date
        }
        
        return self._created_at!        
    }
    
    public func stats(shouldRecordEventByModel model: Model ) -> Bool {
        return false
    }
    
    public func stats(segmentationForEventByModel model: Model )-> [String: AnyObject] {
        return [:]
    }
    
    public func stats(objectStatsByModel model: Model )-> IStats {
        return Stats(model: model)
    }
    
    func ownerIdValue() -> String {
        return idValue("owner_id")
    }
    
    func idValue(property: String) -> String {
        var value: AnyObject? = valueForKey(property);
        
        if (value != nil) {
            return value  as! String
        }
        return ""
    }
    
    func formNamed() -> String {
        return "Model"
    }
    
    required public init(raw: AnyObject) {
        self.data   = raw as! [String: AnyObject]
        self.events = EventManager()
        self.api    = API.crud(self.formNamed())
        self.links = [String: AnyObject]()
    }
    
    required public init(raw: [String: AnyObject]) {
        self.data   = raw
        self.events = EventManager()
        self.api    = API.crud(self.formNamed())
        self.links = [String: AnyObject]()
    }
    
    init() {
        self.data   = [:]
        self.events = EventManager()
        self.api    = API.crud(self.formNamed())
        self.links = [String: AnyObject]()
    }
    
    func handlerLink(raw: Any?) {
        self.performSync(raw as! SwiftyJSON.JSON)
    }
    
    func link(model: AnyObject, forKey: String) {
        self.links![forKey] = model;
    }
    
    func unlink(key: String) {
        self.links!.removeValueForKey(key)
    }
    
    func getLink(key: String)-> AnyObject? {
        return self.links![key]
    }

    func valueForKey(key: String) -> AnyObject? {
        var index = data.indexForKey(key);
        if index != nil {
            return data[key]!
        }
        
        return nil;
    }
    
    func updateValue(forKey key: String, value: AnyObject) {
        data.updateValue(value, forKey: key)
    }
    
    func transformData() -> [String: AnyObject] {
        return self.data;
    }
    
    // MARK: - Handlers
    func handleRemove(req: NSURLRequest, res: NSHTTPURLResponse?, json: SwiftyJSON.JSON, err: NSError?) -> Void {
        if err == nil {
            if json["success"].number == 0 {
                self.performError(NSError(domain: json["errCode"].string!, code: 1, userInfo: [:]))
            } else {
                self.performRemove()
            }
        } else {
            self.performError(err!)
        }
    }
    
    //линковка model
    func handlerExtra(json: SwiftyJSON.JSON) {
        for (key, model) in self.links! {
            if json[key].isEmpty == false {
                (model as! Model).handlerLink(json)
            }
        }
    }

    func handleSync(req: NSURLRequest, res: NSHTTPURLResponse?, json: SwiftyJSON.JSON, err: NSError?) -> Void {
        
        if err == nil {
            if json["success"].number == 0 {
                self.performError(NSError(domain: json["errCode"].string!, code: 1, userInfo: [:]))
            } else {
                self.performSync(json)
            }
        } else {
            self.performError(err!)
        }
    }
    
    func hasFormData(json: SwiftyJSON.JSON) -> Bool {
        var formName    = self.formNamed()
        
        if let data = json[formName].dictionaryObject {
            return true
        }
        
        return false
    }

    func performSync(json: SwiftyJSON.JSON) {
        var formName    = self.formNamed()
        
        if let data = json[formName].dictionaryObject {
            self.data = data
        }
        
        handlerExtra(json);
        
        self.status = StatusSync.Synced
        self.events.trigger("sync", information: self)
    }
    
    func performStartSync() {
        self.status = StatusSync.Syncing
        self.events.trigger("start", information: self)
    }
    
    func performError(err: NSError) {
        self.error  = err
        self.status = StatusSync.Error
        self.events.trigger("error", information: err)
    }
    
    func performRemove() {
        self.data   = [:];
        self.status = StatusSync.Removed
        self.events.trigger("removed", information: self)
    }
    
    func setData(json: SwiftyJSON.JSON) {
        if let data = json.dictionaryObject {
            self.data = data
        }
    }
    
    func setData(data: [String: AnyObject]) {
        self.data = data
    }
    
    // MARK: - Methods
    func save() -> Request {
        var request = self.api!["create"]!(data: transformData())
        
        return handlerRequest(request).responseSuccess({ (req, res, json, err) -> Void in
            if self.stats(shouldRecordEventByModel: self) {
                let stats = self.stats(objectStatsByModel: self)
                let segmentation = self.stats(segmentationForEventByModel: self)
                stats.create( segmentation )
            }
        })
    }
    
    func fetchIfNeeded() {
        //обновить если требуется
        self.fetch()
    }
    
    func fetch() -> Request {
        var data    = ["id": id]
        var request = self.api!["get"]!(data: data)
        
        return handlerRequest(request)
    }
    
    func fetch(id: String) -> Request {
        var data    = ["id": id]
        var request = self.api!["get"]!(data: data)
        
        return handlerRequest(request)
    }
    
    func sync() -> Request {
        if id.isEmpty {
            return save()
        }
        
        var request = self.api!["update"]!(data: transformData())
        return handlerRequest(request)
    }
    
    func runAction(action: String) -> Request {
        var method = API.method(formNamed(), method: action)
        var data: [String: String] = ["id": id]
        var request = method(data: data)
        
        return handlerRequest(request)
    }
    
    func runAction(action: String, var data: [String: AnyObject]) -> Request {
        data.updateValue(getIdValue(), forKey: "id")
        var method = API.method(formNamed(), method: action)
        var request = method(data: data)
        
        return handlerRequest(request)
    }
    
    func handlerRequest(request: RestApiRequest) -> Request {
        performStartSync()
        
        return ServerRestApi.sharedInstance.sendRequest(request)
            .responseSwiftyJSON(handleSync)
    }
    
    func uploadImage() -> Request {
        performStartSync()
        
        var request = API.uploadImage(self.data)
        return ServerRestApi.sharedInstance.uploadImage(request)
                .responseSwiftyJSON(handleSync)
    }
    
    func uploadFile() -> Request {
        performStartSync()
        var request = API.uploadFile(self.data)
        return ServerRestApi.sharedInstance.uploadFile(request)
            .responseSwiftyJSON(handleSync)
    }
    
    func remove() -> Request? {
        if !id.isEmpty {
            var request = self.api!["delete"]!(data: transformData())
            
            return handlerRequest(request).responseSuccess({ (req, res, json, err) -> Void in
                if self.stats(shouldRecordEventByModel: self) {
                    let stats = self.stats(objectStatsByModel: self)
                    let segmentation = self.stats(segmentationForEventByModel: self)
                    stats.remove( segmentation )
                }
            });
        }
        
        return nil
    }
    
    public var description: String{
        return  "[Model] id:" + id
    }
}

public func == (lhs: Model, rhs: Model) -> Bool {
    return lhs.id == rhs.id
}

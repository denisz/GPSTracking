//
//  Collection.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Dollar

protocol ModelProtocol {
    init(raw: AnyObject)
    func attachCollection(collection: CollectionProtocol)
    func getIdValue() -> String
    func idValue(property: String) -> String
    func getCreatedAt() -> NSDate
    func formNamed() -> String
}

protocol CollectionProtocol {
    func handlerLink(raw: Any?)
    func getEventManager() -> EventManager
    func getStatus() -> StatusSync
    func getCount() -> Int
    func more()
    func fetch()
    func removeById(id: String)
    func ifNeedMore() -> Bool
}

class Collection<T: ModelProtocol where T: Equatable>: SequenceType, CollectionProtocol {
    var events: EventManager
    var models: [T]
    var status: StatusSync = .Created
    var api: ((data: [String: AnyObject]) -> RestApiRequest)?
    var data: [String: AnyObject]?
    var filter: IFilter?
    var meta: Model?
    var error: NSError?
    var links: [String: AnyObject]?
    var sortProperty: String = "created_at";
    var sortDirection: Int = -1;
    
    var count: Int {
        get {
            return models.count
        }
    }
    
    func getCount() -> Int {
        return self.count
    }
    
    init() {
        self.events = EventManager()
        self.models = [T]()
        self.links  = [String: AnyObject]()
        self.data   = [String: AnyObject]()
        self.meta   = Model()
    }
    
    func formNamed() -> String {
        let m = T(raw: [:])
        return m.formNamed()
    }
    
    func getStatus() -> StatusSync {
        return self.status
    }
    
    func getEventManager() -> EventManager {
        return self.events
    }
    
    func handlerLink(raw: Any?) {
        self.performSync(raw as! SwiftyJSON.JSON)
    }
    
    func link(collection: AnyObject, forKey: String) {
        let coll = collection as! CollectionProtocol;
        self.events.listenTo("data:" + forKey, action: {(json: Any?) in
            coll.handlerLink(json)
        })
        self.links![forKey] = collection;
    }
    
    func unlink(key: String) {
        self.links!.removeValueForKey(key)
        self.events.removeListeners("data:" + key)
    }
    
    func getLink(key: String)-> AnyObject? {
        return self.links![key]
    }
    
    func use(api: (data: [String: AnyObject]) -> RestApiRequest) {
        self.api = api
    }
    
    func setData(data: [String: AnyObject]) {
        self.data = data
    }
    
    func valueData(key: String) -> AnyObject? {
        return self.data![key]
    }
    
    func setFilter (filter: IFilter) {
        self.filter = filter
    }
    
    func prepent(data: AnyObject) -> T {
        let model: T = T(raw: data)
        return self.prependModel(model, silent: false)
    }
    
    func prependModel(model: T, silent:Bool = false) -> T {
        let exists = self.findById(model.getIdValue())
        
        if exists == nil   {
            model.attachCollection(self)
            self.models.insert(model, atIndex: 0)
            if silent == false {
                self.events.trigger("add", information: model)
            }
        }
        
        return model
    }
    
    func append(data: AnyObject) -> T {
        let model: T = T(raw: data)
        return self.appendModel(model, silent: false)
    }
        
    func appendModel(model: T, silent:Bool = false) -> T {
        let exists = self.findById(model.getIdValue())
        
        if exists == nil   {
            model.attachCollection(self)
            self.models.append(model)
            if silent == false {
                self.events.trigger("add", information: model)
            }
        }
        
        return model
    }
    
    func appendSilent(data: AnyObject) ->T {
        let model: T = T(raw: data)
        return self.appendModel(model, silent: true)
    }
    
    func findById(id: String) -> T? {
        return $.find(self.models, callback: { (item: T) -> Bool in
            return item.getIdValue() == id
        })
    }
    
    func findById(property: String, id: String) -> T? {
        return $.find(self.models, callback: { (item: T) -> Bool in
            return item.idValue(property) == id
        })
    }
    
    func sort() {
        if self.sortDirection == -1 {
            self.models.sortInPlace({ (a: T, b: T) -> Bool in
                return a.getCreatedAt().compare(b.getCreatedAt()) == NSComparisonResult.OrderedDescending
            })
        } else {
            self.models.sortInPlace({ (a: T, b: T) -> Bool in
                return a.getCreatedAt().compare(b.getCreatedAt()) == NSComparisonResult.OrderedAscending
            })
        }
    }
    
    func remove(model: T) {
        let index = indexOf(model);
        
        if let idx = index {
            self.models.removeAtIndex(idx)
            self.events.trigger("remove", information: model)
        }
    }
    
    func removeById(id: String) {
        if let model = self.findById("_id", id: id) {
            self.remove(model)
        }
    }
    
    func empty() {
        self.models.removeAll(keepCapacity: true)
    }
    
    func lastModel() -> T? {
        return self.models.last
    }
    
    func indexOf(model: T) -> Int? {
        return self.models.indexOf(model)
    }
    
    func valueIds() -> [String] {
        var ids = [String]()
        each({(int, model) in
            ids.append(model.getIdValue())
        })
    
        return ids
    }
    
    func firstModel() -> T? {
        return self.models.first
    }
    
    func getModels() -> [T] {
        return models
    }
    
    func each(callback: (Int, T) -> ()) {
        $.each(models, callback: callback)
    }
    
    //может быть nullable
    func valueAtIndex(index: Int) -> T? {
        return self.models[index]
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
    
    func handlerExtra(json: SwiftyJSON.JSON) {
        let list = json["extra"].dictionary
        
        if list != nil {
            for (key, json) in list! {
                self.events.trigger("data:" + key, information: json)
            }
        }
    }
    
    func ifNeedMore() -> Bool {

        if let more = self.meta!.valueForKey("more") as? Bool {
            return more
        }
        
        return false
    }
    
    func performSync(json: SwiftyJSON.JSON) {
        //распарсить структуру списка
        let list = json["items"].arrayValue
        
        for item in list {
            self.appendSilent(item.dictionaryObject!)
        }
        
        handlerExtra(json)
        performMeta(json)
        
        self.status = .Synced
        self.events.trigger("sync", information: self)
    }
    
    func performMeta(json: SwiftyJSON.JSON) {
        let meta = json["meta"]
        if meta != nil {
            self.meta!.setData(meta)
        }
    }
    
    func performStartSync() {
        self.status = .Syncing
        self.events.trigger("start", information: self)
    }
    
    func performError(err: NSError) {
        self.error  = err
        self.status = .Synced
        self.events.trigger("error", information: err)
    }
    
    func fetch() {
        let data = prepareDataRequest(conditionLisRefresh())
        let request = self.api?(data: data)
        
        handlerRequest(request!)
    }
    
    func sync() {
        let data = prepareDataRequest(conditionListMore())
        let request = self.api?(data: data)
        
        handlerRequest(request!)
    }
    
    func more() {
        if status != StatusSync.Syncing {
            let data = prepareDataRequest(conditionListMore())
            let request = self.api?(data: data)
            
            handlerRequest(request!)
        }        
    }
    
    func handlerRequest(request: RestApiRequest) -> Request {
        performStartSync()
        
        return ServerRestApi.sharedInstance.sendRequest(request)
            .responseSwiftyJSON(handleSync)
    }
    
    func pullToRefresh() {
        self.fetch()
    }
    
    func update() {
        
    }
    
    func prepareDataRequest(dataList: [String: AnyObject]) -> [String: AnyObject] {
        if (self.filter != nil) {
            let data = self.filter!.serialize()
            return $.merge(dataList, data)
        }
        
        return dataList
    }
    
    func conditionListMore() -> [String: AnyObject] {
        var data: [String: AnyObject] = self.data!
        
        let last = self.lastModel()
        
        if last != nil {
            data["last_id"] = (last as! Model).id
        } 

        return data
    }
    
    func conditionLisRefresh() -> [String: AnyObject] {
        var data: [String: AnyObject] = self.data!
        
        let last = self.firstModel()
        
        if last != nil {
            data["first_id"] = (last as! Model).id
        }
        
        return data
    }
    
    typealias Generator = AnyGenerator<T>
    
    func generate() -> Generator {
        var index = 0
        return anyGenerator {
            if index < self.models.count {
                return self.models[index++]
            }
            return nil
        }
    }
}
//
//  MapSupport.swift
//  GPSTracking
//
//  Created by denis zaytcev on 8/8/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class MapSupport: NSObject {
    var collection: Collection<Event>?
    var timeInterval: NSTimeInterval = 50.0//чекаем место положение каждые 10 сек
    var timer: NSTimer?

    class var sharedInstance: MapSupport {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: MapSupport? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = MapSupport()
        }
        
        return Static.instance!
    }
    
    override init() {
    }
    
    func initialize(collection: Collection<Event>) {
        self.collection = collection
        self.bindEvents()
        self.startTimer()
    }
    
    func bindEvents() {
//        Dispatcher.sharedInstance.events.listenTo(KEY_REMOVE_EVENT, action: self.removeByEvent)
    }
    
    func removeById(id: String) {
        self.collection?.removeById(id)
    }
    
    func removeByModel(model: Event) {
        self.collection?.removeById(model.id)
    }
    
    func addPoint(model: Event) {
        collection?.appendModel(model, silent: false)
    }
    
    func timerDidFire(timer: NSTimer) {
        updater()
    }
    
    func removeByEvent(eventData: Any?) {
        if let model = eventData as? Event {
            self.collection?.removeById(model.id)
        }
    }
    
    func startTimer() {
        stopTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target:self, selector: "timerDidFire:", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
        }
    }

    
    func updater() {
        var removed = [Event]()
        
        self.collection?.each({ (index: Int, model: Event) -> () in
            if model.visible_map_at < AppHelp.dateNow() || model.defineStatus == kEventDefineStatusCanceled {
                removed.append(model)
            }
        })
        
        for model in removed {
            self.collection?.remove(model)
        }
    }
}
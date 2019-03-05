//
//  Event.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import SwiftyJSON
import Dollar

let kEventDefineStatusCanceled = "canceled"
let kEventDefineStatusActive = "active"
let kEventDefineStatusBanned = "banned"

let kEventWithSpectator = ["3", "7"] as [String]

class Event: Model {
    override func formNamed() -> String {
        return "event"
    }
    
    override var description: String {
        return "[Event] id:" + (self.valueForKey("localized_loc") as! String)
    }
    
    var criteria: [String: AnyObject]? {
        return self.valueForKey("criteria") as? [String: AnyObject]
    }
    
    var context: String? {
        if let criteria = self.criteria {
            return criteria["context"] as? String
        }

        return nil
    }
    
    var subtype: String? {
        if let criteria = self.criteria {
            return criteria["subtype"] as? String
        }
        
        return nil
    }
    
    var localizedContext: String {
        if let context = self.context {
            return EventHelper.contextByValue(context)!["title"] as! String
        }
    
        return ""
    }
    
    var combineContext: String {
        let localizedContext = self.localizedContext
        _ = self.localizedSubtype
        
        if !localizedSubtype.isEmpty {
            return "\(localizedContext) : \(localizedSubtype)"
        }
        
        return localizedContext
    }
    
    var localizedSubtype: String {
        if let subtype = self.subtype {
            return EventHelper.subtypeByValue(subtype)!["title"] as! String
        }
        
        return ""
    }
    
    var localizedLocation: String {
        if let loc = self.valueForKey("localized_loc") as? String {
            return loc
        }
        
        return ""
    }
    
    var allowPhone: Bool {
        if let isAllowPhone = self.valueForKey("allow_phone") as? Int {
            return isAllowPhone != 0
        }
        
        return false
    }
    
    var allowEmail: Bool {
        if let isAllowEmail = self.valueForKey("allow_email") as? Int {
            return isAllowEmail != 0
        }
        
        return false
    }
    
    var allow_contact: Bool {
        let result = allowPhone || allowEmail;
        return result;
    }
    
    func collectionAnswer() -> Collection<Answer> {
        
        let _answers = Collection<Answer>()
        _answers.link(Collection<User>(), forKey: "user")
        _answers.use(API.list("answer", destination: "event")) //answer/list/event
        _answers.setData(["event_id": id])

        return _answers
    }

    func collectionAttachments() -> Collection<Attachment> {
        let _attachments = Collection<Attachment>();
        _attachments.use(API.list("attachment", destination: "target")) //attachment/list/target
        _attachments.setData(["target_id": id])

        return _attachments
    }
    
    func collectionSpectartor() -> Collection<Event> {
        let _events = Collection<Event>()
        _events.link(Collection<User>(), forKey: "user")
        _events.use(API.list("event", destination: "spectator")) //event/list/spectator
        _events.setData(["id": id])
        
        return _events
    }
    
    func withSpectators() -> Bool {
        if let context = self.context {
            return kEventWithSpectator.contains(context)
        }
        return false
    }
    
    func isOwner(model: User) -> Bool {
        let user_id = model.getIdValue()
        let owner_id = ownerIdValue()
        
        return user_id == owner_id
    }
    
    func isOwnerCurrentUser() -> Bool {
        let currentUser = ServerRestApi.sharedInstance.getUser()
        return isOwner(currentUser!)
    }
    
    func getOwner() -> User{
        return User(raw: ["_id" : ownerIdValue()])
    }
    
    func copyWithUser() -> Event {
        return Event.withUser(getIdValue());
    }
    
    func copyWithUserAndAnswer() -> Event {
        return Event.withUserAndAnswer(getIdValue())
    }
    
    var visible_map_at: NSDate {
        let visible_map_at = valueForKey("visible_map_at") as! String
        return AppHelp.convertDate(visible_map_at)
    }
    
    var canceled_at: NSDate {
        let canceled_at = valueForKey("canceled_at") as! String
        return AppHelp.convertDate(canceled_at)
    }
    
    var defineStatus: String {
        let status      = valueForKey("status") as! String
        let canceled_at = self.canceled_at
        let nowDate     = AppHelp.dateNow()
    
        if status == kEventDefineStatusCanceled {
            return status
        }
        
        if  canceled_at < nowDate {
            return kEventDefineStatusCanceled
        }
    
        return  status
    }
    
    override func stats(shouldRecordEventByModel model: Model ) -> Bool {
        return true
    }
    
    override func stats(segmentationForEventByModel model: Model )-> [String: AnyObject] {
        let data = $.pick(self.data, keys: "criteria")
        return data["criteria"] as! [String: AnyObject]
    }
    
    func location() -> CLLocation {
        let loc = valueForKey("loc") as! [String: AnyObject]
        let coords = loc["coordinates"] as! [Double]
        return CLLocation(latitude: coords[1], longitude: coords[0])
    }
    
    func destinationLocation() -> CLLocation? {
        if let extra = self.extraCriteria {
            print(extra["destination"])
            if let coord = extra["destination"] as? [Double] {
                return CLLocation(latitude: coord[0] as CLLocationDegrees, longitude: coord[1] as CLLocationDegrees)
            }
        }
        
        return nil
    }
    
    var extraCriteria: [String: AnyObject]? {
        if let criteria = self.criteria {
            return criteria["extra"] as? [String: AnyObject]
        }
        
        return nil
    }
    
    class func withUserAndAnswer(id: String) -> Event {
        let event = Event(raw: ["_id": id])
        event.link(User(), forKey: "user")
        event.link(Answer(), forKey: "answer")
        event.link(Favorite(), forKey: "favorite")
        return event;
    }
    
    class func withUser(id: String) -> Event {
        let event = Event(raw: ["_id": id])
        event.link(User(), forKey: "user")
        
        return event;
    }
    
    class func hasAnswer(model: Event) -> Bool {
        if let answer = model.getLink("answer") as? Answer {
            return answer.isSync()
        }
        
        return false
    }
}

func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
}







//
//  Event.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import SwiftyJSON

class Event: Model {
    var _attachments: Collection<Attachment>?
    var _answers: Collection<Answer>?
    
    override func formNamed() -> String {
        return "event"
    }
    
    override var description: String {
        return "[Event] id:" + (self.valueForKey("localized_loc") as! String)
    }
    
    func collectionAnswer() -> Collection<Answer> {
        if let col = self._answers {
            return col
        }
        
        self._answers = Collection<Answer>()
        self._answers!.link(Collection<User>(), forKey: "user")
        self._answers!.use(API.list("answer", destination: "event")) //answer/list/event
        self._answers!.setData(["event_id": id])

        return self._answers!
    }

    func collectionAttachments() -> Collection<Attachment> {
        if let col = self._attachments {
            return col;
        }
        
        self._attachments = Collection<Attachment>();
        self._attachments!.use(API.list("attachment", destination: "event")) //attachment/list/event
        self._attachments!.setData(["target_id": id])

        return self._attachments!
    }
    
    func isOwner(model: User) -> Bool {
        var user_id = model.getIdValue()
        var owner_id = self.ownerIdValue()
        
        return user_id == owner_id
    }
    
    func isOwnerCurrentUser() -> Bool {
        var currentUser = ServerRestApi.sharedInstance.getUser()
        return isOwner(currentUser!)
    }
    
    func copyWithUser() -> Event {
        var event = Event(raw: ["_id": getIdValue()])
        var user = User()
        event.link(user, forKey: "user")
        
        return event;
    }
    
    func copyWithUserAndAnswer() -> Event {
        var event = Event(raw: ["_id": getIdValue()])
        event.link(User(), forKey: "user")
        event.link(Answer(), forKey: "answer")
        
        return event;

    }
    
    func location() -> CLLocation {
        var loc = valueForKey("loc") as! [String: AnyObject]
        var coords = loc["coordinates"] as! [Double]
        return CLLocation(latitude: coords[1], longitude: coords[0])
    }
}

func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
}







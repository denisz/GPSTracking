//
//  UserModel.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/25/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation



class User: Model {
    var _comments: Collection<Comment>?
    
    var email : String {
        get {
            return valueForKey("email") as! String
        }
    }
    
    var phone: String? {
        return valueForKey("phone") as? String
    }
    
    override func formNamed() -> String {
        return "user"
    }
    
    func copy() -> User {
        return User(raw: ["_id": getIdValue()]);
    }
    
    //все запросы
    func collectionEvents() -> Collection<Event> {
        let events = Collection<Event>()
        events.link(Collection<User>(), forKey: "user")
        events.use(API.list("event", destination: "user")) //event/list/user
        events.setData(["owner_id": id])
        return events
    }
    
    //активные
    func collectionMyActive() -> Collection<Event> {
        let events = Collection<Event>()
        events.link(Collection<User>(), forKey: "user")
        events.use(API.list("event", destination: "active")) //event/list/active
        events.setData(["owner_id": id])
        return events
    }
    
    //отменненые
    func collectionMyCanceled() -> Collection<Event> {
        let events = Collection<Event>()
        events.link(Collection<User>(), forKey: "user")
        events.use(API.list("event", destination: "canceled")) //event/list/cancelled
        events.setData(["owner_id": id])
        return events
    }
    
    //отменненые
    func collectionMyFavorites() -> Collection<Event> {
        let events = Collection<Event>()
        events.link(Collection<User>(), forKey: "user")
        events.use(API.list("favorite", destination: "user")) //favorite/list/user
        events.setData(["owner_id": id])
        return events
    }
    
    func collectionNear() -> Collection<Event> {
        let events = Collection<Event>()
        events.link(Collection<User>(),     forKey: "user")//их нету
        events.link(Collection<Answer>(),   forKey: "answer")
        events.use(API.list("event", destination: "near")) //event/list/near
        events.setData(["owner_id": id])
        return events
    }
    
    func collectionPerform() -> Collection<Answer> {
        let answer = Collection<Answer>()
        answer.link(Collection<User>(), forKey: "user")
        answer.link(Collection<Event>(), forKey: "event")
        answer.use(API.list("answer", destination: "perform")) //answer/list/perform
        answer.setData(["owner_id": id])
        return answer
    }
    
    func collectionComments() -> Collection<Comment> {
        if let col = self._comments {
            return col
        }
        
        self._comments = Collection<Comment>()
        return self._comments!
    }
    
    func absolutePathForAvatar() -> NSURL {
        if let path = self.valueForKey("avatar") as? String {
            return ServerCDN.sharedInstance.absolutePath(path)
        }
        
        return NSBundle.mainBundle().URLForResource("man3", withExtension: "jpg")!
    }
    
    //было бы здорово брать из аттачмента
    func absolutePathForCover() -> NSURL {
        if let path = self.valueForKey("cover") as? String {
            return ServerCDN.sharedInstance.absolutePath(path)
        }
        
        return NSBundle.mainBundle().URLForResource("man3", withExtension: "jpg")!
    }
    
    func absolutePathForCover(origin: Bool) -> NSURL {
        
        
        if let path = self.valueForKey("cover") as? String {
            if origin {
                let originPath = (path ).stringByReplacingOccurrencesOfString("_s.", withString: ".")
                return ServerCDN.sharedInstance.absolutePath(originPath)
            }
            return ServerCDN.sharedInstance.absolutePath(path)
        }
        
        return NSBundle.mainBundle().URLForResource("man3", withExtension: "jpg")!
    }
    
    func avatarFromAttachment(attachment: Attachment) {
        self.updateValue(forKey: "avatar", value: attachment.relativePathThumbS())
        self.updateValue(forKey: "cover",  value: attachment.relativePathThumbB())
    }
    
    override var description: String{
        return  "User with email " + email
    }
    
    func isCurrentUser() -> Bool {
        let currentUser = ServerRestApi.sharedInstance.getUser()
        return currentUser!.getIdValue() == getIdValue()
    }
    
    func fullname() -> String {
        if let fullname = self.valueForKey("fullname") as? String {
            return fullname
        }
        
        return ""
    }
    
    class func create (userData: [String : AnyObject]) -> User {
        return User(raw: userData)
    }
}

func == (lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}


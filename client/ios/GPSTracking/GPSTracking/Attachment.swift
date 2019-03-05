//
//  Event.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Attachment: Model {
    var _ispectators: Collection<User>?
    var _comments: Collection<Comment>?
    
    override func formNamed() -> String {
        return "attachment"
    }
    
    override var description: String {
        return "[Attachment] id:" + self.id
    }
    
    func relativePath() -> String {
        return self.valueForKey("path") as! String
    }
    
    func relativePathThumbS() -> String {
        return self.valueForKey("thumb_s") as! String
    }
    
    func relativePathThumbB() -> String {
        return self.valueForKey("thumb_b") as! String
    }
    
    func absoluteUrl() -> NSURL {
        return ServerCDN.sharedInstance.absolutePath(relativePath())
    }
    
    func absoluteUrlThumbS() -> NSURL {
        return ServerCDN.sharedInstance.absolutePath(relativePathThumbS())
    }
    
    func absoluteUrlThumbB() -> NSURL {
        return ServerCDN.sharedInstance.absolutePath(relativePathThumbB())
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
    
    func target(target: Model) {
        let target_id: String = target.getIdValue()
        let current_target_id = getIdValue()
        
        if target_id != current_target_id {
            self.runAction("target", data: ["target_id" : target_id])
        }        
    }
    
    class func withImage(image: UIImage) -> Attachment {
        return Attachment(raw: ["image" : image])
    }
    
    class func withImage(image: UIImage, scenario: String) -> Attachment {
        return Attachment(raw: ["image" : image, "scenario" : scenario])
    }
    
    class func scopeToTarget(collection: Collection<Attachment>, target: Model) -> Request {
        let target_id: String = target.getIdValue()
        let ids = collection.valueIds()
        let request = API.method("attachment", method: "list/scope")(data: [ "ids": ids, "target_id" : target_id ]);
        
        return ServerRestApi.sharedInstance.sendRequest(request)
    }
}

func == (lhs: Attachment, rhs: Attachment) -> Bool {
    return lhs.id == rhs.id
}





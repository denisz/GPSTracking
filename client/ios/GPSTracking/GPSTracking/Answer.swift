//
//  Answer
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class Answer: Model {
    override func formNamed() -> String {
        return "answer"
    }
    
    override var description: String {
        return "[Answer] id:" + id
    }
    
    func location() -> CLLocation {
        let loc = valueForKey("loc") as! [String: AnyObject]
        let coords = loc["coordinates"] as! [Double]
        return CLLocation(latitude: coords[1], longitude: coords[0])
    }
    
    func collectionComments() -> Collection<Comment> {
        let _comments = Collection<Comment>();
        _comments.link(Collection<User>(), forKey: "user")
        _comments.use(API.list("comment", destination: "answer")) //comment/list/answer
        _comments.setData(["target_id": getObjectIdValue()])

        return _comments
    }
    
    func getOwner() -> User{
        return User(raw: ["_id" : ownerIdValue()])
    }
    
    func isOwner(model: User) -> Bool {
        let user_id = model.getIdValue()
        let owner_id = ownerIdValue()
        
        return user_id == owner_id
    }
    
    func eventId() -> String {
        return self.idValue("event_id")
    }
    
    func isOwnerCurrentUser() -> Bool {
        let currentUser = ServerRestApi.sharedInstance.getUser()
        return isOwner(currentUser!)
    }
    
    func changeStatus(status: String) {
        self.updateValue(forKey: "status", value: status)
        self.save()
    }
    
    func isRejected() -> Bool {
        let status  = valueForKey("status") as! String
        return status == ANSWER_REJECTED
    }
    
    func isAccept() -> Bool {
        let status  = valueForKey("status") as! String
        return status == ANSWER_ACCEPTED
    }
    
    func collectionAttachments() -> Collection<Attachment> {
        let _attachments = Collection<Attachment>();
        _attachments.use(API.list("attachment", destination: "target")) //attachment/list/target
        _attachments.setData(["target_id": id])
        
        return _attachments
    }
    
    func createComment(body: String) -> Comment {
        return Comment(raw: ["body": body, "target_id": getObjectIdValue()])
    }
    
    class func createFromEvent(model: Event, data: [String: AnyObject]) -> Answer {
        let answer = Answer(raw: data)
        answer.updateValue(forKey: "event_id", value: model.getIdValue())
        return answer
    }
}

func == (lhs: Answer, rhs: Answer) -> Bool {
    return lhs.id == rhs.id
}

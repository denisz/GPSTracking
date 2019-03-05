//
//  Angry.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

class Angry: Model {
    override func formNamed() -> String {
        return "angry"
    }
    
    var count: Int {
        return valueForKey("count") as! Int
    }
    
    override var description: String {
        return "[Angry] id:" + id;
    }
    
    //жалоба, создаем по модели у которой есть objectID
    class func createFromModel(model: Model, reason: Int) -> Angry {
        return Angry(raw: ["reason": reason, "target_id": model.getObjectIdValue()])
    }
    
    func getOwner() -> User{
        return User(raw: ["_id" : ownerIdValue()])
    }
}

func == (lhs: Angry, rhs: Angry) -> Bool {
    return lhs.id == rhs.id
}

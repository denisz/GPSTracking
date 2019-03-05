//
//  Favorite.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

class Favorite: Model {
    override func formNamed() -> String {
        return "favorite"
    }
    
    override var description: String {
        return "[Favorite] id:" + id;
    }
    
    class func createFromEvent(model: Event) -> Favorite {
        let favorite = Favorite(raw: ["event_id": model.getIdValue()])
        return favorite
    }
    
    func getOwner() -> User{
        return User(raw: ["_id" : ownerIdValue()])
    }
}

func == (lhs: Favorite, rhs: Favorite) -> Bool {
    return lhs.id == rhs.id
}

//
//  Comment.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/4/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation


class Comment: Model {
    override func formNamed() -> String {
        return "comment"
    }

    override var description: String {
        return "[Commend] id:" + id;
    }
    
    func getOwner() -> User{
        return User(raw: ["_id" : ownerIdValue()])
    }
}

func == (lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
}

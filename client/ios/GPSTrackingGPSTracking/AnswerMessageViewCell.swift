//
//  AnswerMessageViewCell.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit


class AnswerMessageViewCell: UITableViewCell {
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var fullnameView: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.bounds = UIScreen.mainScreen().bounds
    }
    
    func prepareUserView(model: User) {
        fullnameView.text = model.fullname()
    }

    func prepareCommentView(model: Comment) {
        var body        = model.valueForKey("body") as? String
        
        if body != nil {
            self.bodyView.text = body
        } else {
            self.bodyView.text = "Без комментария"
        }
    }
    
    func prepareView(model: Comment, collection: Collection<Comment>) {
        prepareCommentView(model)
        
        var users = collection.getLink("user") as! Collection<User>
        var user = users.findById(model.ownerIdValue())
        if user != nil {
            prepareUserView(user!)
        }
    }
}
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
    var model: Comment?
    var parentNavigationController: UINavigationController?
    
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.bounds = UIScreen.mainScreen().bounds
    }
    
    @IBAction func didTapAvatar() {
        if self.parentNavigationController != nil {
            let pvc: ProfileViewController! = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
            
            pvc.loadModel(model!.getOwner())
            self.parentNavigationController?.pushViewController(pvc, animated: true)
        }
    }
    
    func prepareUserView(model: User) {
        let gestureAvatar = UITapGestureRecognizer(target: self, action: "didTapAvatar")
        self.avatar.addGestureRecognizer(gestureAvatar)
        self.avatar.tag = 0
        
        self.fullname.text = model.fullname()
        self.avatar.kf_setImageWithURL(model.absolutePathForAvatar())
        
        self.dateView.text = AppHelp.formatDate(model.createdAt)
    }

    func prepareCommentView(model: Comment) {
        self.model = model
        let body = model.valueForKey("body") as? String
        
        if body != nil {
            self.bodyView.text = body
        } else {
            self.bodyView.text = "Без комментария"
        }
    }
    
    func prepareView(model: Comment, collection: Collection<Comment>) {
        prepareCommentView(model)
        
        let users = collection.getLink("user") as! Collection<User>
        if let user = users.findById(model.ownerIdValue()) {
            prepareUserView(user)
        } else {
            prepareUserView(ServerRestApi.sharedInstance.getUser()!)
        }
    }
}
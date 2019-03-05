//
//  AsnwerTableViewCell.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/23/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

import SwiftyJSON

class AnswerTableViewCell: UITableViewCell {
    var parentNavigationController: UINavigationController?
    var model: Answer?
    
    @IBOutlet weak var dateView: UILabel?
    @IBOutlet weak var bodyView: UILabel?
    @IBOutlet weak var fullname: UILabel?
    @IBOutlet weak var avatar: UIImageView?

    func prepareAnswerView(model: Answer) {
        self.model = model;
        
        let body = model.valueForKey("description") as? String
        
        if body != nil {
            self.bodyView?.text = body
        } else {
            self.bodyView?.text = "Без комментария".localized
        }
        
        self.dateView?.text = AppHelp.formatDate(model.createdAt)
    }
    
    func prepareUserView(model: User) {
        let gestureAvatar = UITapGestureRecognizer(target: self, action: "didTapAvatar")
        self.avatar!.addGestureRecognizer(gestureAvatar)
        self.avatar!.tag = 0

        self.fullname!.text = model.fullname()
        self.avatar!.kf_setImageWithURL(model.absolutePathForAvatar())
    }
    
    func prepareBackgroundView(model: Answer) {
        
    }
    
    @IBAction func didTapAvatar() {
        print("tap avatar")
        
        if self.parentNavigationController != nil {
            let pvc: ProfileViewController! = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
            
            pvc.loadModel(model!.getOwner())
            self.parentNavigationController?.pushViewController(pvc, animated: true)
        }
    }
    
    func prepareView(model: Answer, collection: Collection<Answer>) {
        prepareAnswerView(model)
        
        if let users = collection.getLink("user") as? Collection<User> {
            if let user = users.findById(model.ownerIdValue()) {
                prepareUserView(user)
            }
        }
    }
}
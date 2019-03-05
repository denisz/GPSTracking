//
//  EventTableViewCell.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/12/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher

class EventTableViewCell: UITableViewCell {
    var model: Event?
    var parentNavigationController: UINavigationController?
    
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var context: UILabel!
    @IBOutlet weak var location: LocationView!
    @IBOutlet weak var fullnameView: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var statusView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func prepareUserView(model: User) {
        let gestureAvatar = UITapGestureRecognizer(target: self, action: "didTapAvatar")
        self.avatar.addGestureRecognizer(gestureAvatar)
        self.avatar.tag = 0
        
        self.fullnameView.text = model.fullname()
        self.avatar.kf_setImageWithURL(model.absolutePathForAvatar())
    }
    
    func prepareEventView(model: Event) {
        let localizedLocation   = model.localizedLocation
        let localizedContext    = model.combineContext //model.localizedContext
        
        self.location.changeTintColor(defineColorStatus(self.model!))
        
        self.dateView.text = AppHelp.formatDate(model.createdAt)
        self.location.text = localizedLocation
        self.context.text  = localizedContext
    }
    
    func prepareAnswerView(model: Answer) {
        self.statusView.hidden = false
        self.statusView.backgroundColor = self.defineBackground(model)
    }
    
    func defineBackground(model: Answer)-> UIColor {
        let status = model.valueForKey("status") as! String;

        switch status {
            case "accepted":
                return UIColor(red:0.22, green:0.79, blue:0.45, alpha:1)
            case "rejected":
                return UIColor(red:0.9, green:0.3, blue:0.26, alpha:1)
            default:
                return UIColor.whiteColor()
        }
    }
    
    func defineColorStatus(model: Event)-> UIColor {
        
        switch model.defineStatus {
        case kEventDefineStatusActive:
            return UIColor(red:0.22, green:0.79, blue:0.45, alpha:1)
        case kEventDefineStatusCanceled:
            return UIColor(red:0.9, green:0.3, blue:0.26, alpha:1)
        default:
            return UIColor.whiteColor()
        }
    }
    
    @IBAction func didTapAvatar() {
        if self.parentNavigationController != nil {
            let pvc: ProfileViewController! = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
            
            pvc.loadModel(model!.getOwner())
            self.parentNavigationController?.pushViewController(pvc, animated: true)
        }
    }
    
    func prepareView(model: Answer, collection: Collection<Answer>) {
        if let events = collection.getLink("event") as? Collection<Event> {
            if let event = events.findById(model.eventId()) {
                self.model = event
                self.prepareEventView(event)
                
                if let users = collection.getLink("user") as? Collection<User> {
                    if let user = users.findById(event.ownerIdValue()) {
                        self.prepareUserView(user)
                    }
                }
            }
        }

        self.prepareAnswerView(model)
    }
    
    func prepareView(model: Event, collection: Collection<Event>) {
        self.model = model
        prepareEventView(model)
        
        if let users = collection.getLink("user") as? Collection<User> {
            if let user = users.findById(model.ownerIdValue()) {
                prepareUserView(user)
            }
        }
        
        if let answers = collection.getLink("answer") as? Collection<Answer> {
            if let answer = answers.findById("event_id", id: model.getIdValue()) {
                prepareAnswerView(answer)
            }
        }
    }
}

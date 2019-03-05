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

class EventTableViewCell: UITableViewCell {
    var model: Event?
    
    @IBOutlet var dateView: UILabel?
    @IBOutlet var context: UILabel?
//    @IBOutlet var desc: UILabel?
    @IBOutlet var location: UILabel?
    @IBOutlet var fullnameView: UILabel?
    @IBOutlet var avatar: UIImageView?
    @IBOutlet var statusView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func prepareUserView(model: User) {
        fullnameView!.text = model.fullname()
    }
    
    func prepareEventView(model: Event) {
//        var desc        = model.valueForKey("description") as? String
        var rawDate     = model.valueForKey("created_at") as! String
        
        var criteria            = model.valueForKey("criteria") as! [String: AnyObject]
        var context             = criteria["context"] as! String
        var localizedLocation   = model.valueForKey("localized_loc") as! String
        var localizedContext    = EventHelper.contextByValue(context)!["title"] as! String
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        let date = dateFormatter.dateFromString(rawDate)
        
//        if desc != nil {
//            self.desc!.text = desc
//        } else {
//            self.desc!.text = ""
//        }
        
        self.dateView!.text = date!.timeAgo
        self.location!.text = localizedLocation
        self.context!.text = localizedContext
    }
    
    func prepareAnswerView(model: Answer) {
        self.statusView!.hidden = true
        self.statusView!.backgroundColor = self.defineBackground(model)
    }
    
    func defineBackground(model: Answer)-> UIColor {
        var status = model.valueForKey("status") as! String;
        
        switch status {
            case "accepted":
                return UIColor(red:0.22, green:0.79, blue:0.45, alpha:0.2)
            case "rejected":
                return UIColor(red:0.9, green:0.3, blue:0.26, alpha:0.2)
            default:
                return UIColor.whiteColor()
        }
    }
    
    func prepareView(model: Event, collection: Collection<Event>) {
        self.model = model
        prepareEventView(model)
        
        var users = collection.getLink("user") as! Collection<User>
        var user = users.findById(model.ownerIdValue())
        if user != nil {
            prepareUserView(user!)
        }
        
        var answers = collection.getLink("answer") as? Collection<Answer>;
        
        if answers != nil {
            var answer = answers!.findById("event_id", id: model.getIdValue())
            if answer != nil {
                prepareAnswerView(answer!)
            }
        }
    }
}

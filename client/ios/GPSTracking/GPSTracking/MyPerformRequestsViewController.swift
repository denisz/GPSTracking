//
//  MyRequestsViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/17/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class MyPerformRequestsViewController: RequestsViewController {
    override func viewDidLoad() {
        self.parentNavigationController = self.navigationController
        
        let currentUser = ServerRestApi.sharedInstance.getUser()
        
        if let user = currentUser {
            collection = user.collectionPerform()
        } else {
            collection = Collection<Answer>()
        }
        
        super.viewDidLoad()
        
        configureNavigationController()
        
        setupViews()
    }
    
    func configureNavigationController() {
        if let nc = self.navigationController {
            nc.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            nc.navigationBar.barStyle = UIBarStyle.Default
            nc.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
        }
    }
    
    func getEventByAnswer(model: Answer) -> Event?{
        let collection = self.collection as! Collection<Answer>
        
        if let events = collection.getLink("event") as? Collection<Event> {
            if let event = events.findById(model.eventId()) {
                return event
            }
        }

        return nil
    }
    
    override func tableView(tableView: UITableView, customDidSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let requestViewController: MyNavigationController = UIStoryboard(name: "Request", bundle: nil).instantiateViewControllerWithIdentifier("requestController") as! MyNavigationController
        
        let answer = (collection as! Collection<Answer>).valueAtIndex(indexPath.row)
        
        //создаем новый
        if answer != nil {
            if let model = self.getEventByAnswer(answer!) {
                let copy = model.copyWithUserAndAnswer()
                let rvc = requestViewController.visibleViewController as! RequestViewController
                rvc.loadModel(copy)
                
                if self.parentNavigationController != nil {
                    self.parentNavigationController!.pushViewController(rvc, animated: true)
                } else {
                    self.navigationController!.pushViewController(rvc, animated: true)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, customcellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: EventTableViewCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIndetifier()) as! EventTableViewCell
        
        if self.parentNavigationController != nil {
            cell.parentNavigationController = self.parentNavigationController!
        }
        
        let model = (collection as! Collection<Answer>).valueAtIndex(indexPath.row)
        if model != nil {
            cell.prepareView(model!, collection: collection as! Collection<Answer>)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
}
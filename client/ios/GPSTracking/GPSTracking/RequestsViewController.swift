//
//  MyRequestsViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/17/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import StatefulViewController

let reuseIdentifierEvent = "EventTableViewCell"

class RequestsViewController: MyCollectionTableView {
    override func nibViewCell() -> String {
        return "EventTableViewCell"
    }
    
    override func reuseIndetifier() -> String {
        return reuseIdentifierEvent
    }
    
    override func tableView(tableView: UITableView, customDidSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let requestViewController: MyNavigationController = UIStoryboard(name: "Request", bundle: nil).instantiateViewControllerWithIdentifier("requestController") as! MyNavigationController
        
        let model = (collection as! Collection<Event>).valueAtIndex(indexPath.row)
        //создаем новый
        if model != nil {
            let copy = model!.copyWithUserAndAnswer()
            let rvc = requestViewController.visibleViewController as! RequestViewController
            rvc.loadModel(copy)
            
            if self.parentNavigationController != nil {
                self.parentNavigationController!.pushViewController(rvc, animated: true)
            } else {
                self.navigationController!.pushViewController(rvc, animated: true)
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, customcellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: EventTableViewCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIndetifier()) as! EventTableViewCell
        
        if self.parentNavigationController != nil {
            cell.parentNavigationController = self.parentNavigationController!
        }
        
        let model = (collection as! Collection<Event>).valueAtIndex(indexPath.row)
        if model != nil {
            cell.prepareView(model!, collection: collection as! Collection<Event>)
        }
        
        return cell
    }
}
//
//  AnswerViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/21/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import StatefulViewController

let reuseIdentifierAnswer = "AnswerTableViewCell"

class RequestAnswerViewController: MyCollectionTableView {
    var model: Event?
    
    override func nibViewCell() -> String {
        return "AnswerTableViewCell"
    }
    
    override func reuseIndetifier() -> String {
        return reuseIdentifierAnswer
    }
    
    override func viewDidLoad() {
        collection = self.model?.collectionAnswer()
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, customDidSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let collection = self.collection as! Collection<Answer>
        let model = collection.valueAtIndex(indexPath.row)
        
        if model != nil {
            let avc = UIStoryboard(name: "FastAnswerViewController", bundle: nil).instantiateViewControllerWithIdentifier("FastAnswerViewController") as! FastAnswerViewController
            
            avc.loadModel(model!)
        
            let users = collection.getLink("user") as! Collection<User>
            
            if let user = users.findById(model!.ownerIdValue()) {
                avc.loadModel(user)
            }
        
            if self.parentNavigationController != nil {
                avc.parentNavigationController = self.parentNavigationController
                self.parentNavigationController!.pushViewController(avc, animated: true)
            } else {
                avc.parentNavigationController = self.navigationController
                self.navigationController!.pushViewController(avc, animated: true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    override func tableView(tableView: UITableView, customcellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: AnswerTableViewCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIndetifier()) as! AnswerTableViewCell
        
        if self.parentNavigationController != nil {
            cell.parentNavigationController = self.parentNavigationController!
        }
        
        let collection = self.collection as! Collection<Answer>
        if let model = collection.valueAtIndex(indexPath.row) {
            cell.prepareView(model, collection: collection)
        }
        
        return cell
    }
}
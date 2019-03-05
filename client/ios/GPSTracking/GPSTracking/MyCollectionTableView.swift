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

let reuseIndetifierMore = "MoreViewCell"

class MyCollectionTableView: StatefulViewController, StatefulViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var collection: CollectionProtocol?
    var refreshControl: UIRefreshControl?
    var parentNavigationController : UINavigationController?
    
    func nibViewCell() -> String {
        return "tableViewCell"
    }
    
    func reuseIndetifier() -> String {
        return reuseIdentifierEvent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.attachCollection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.registerNib(UINib(nibName: nibViewCell(), bundle: nil),
            forCellReuseIdentifier: reuseIndetifier())
        
        self.tableView.registerNib(UINib(nibName: "MoreViewCell", bundle: nil), forCellReuseIdentifier: reuseIndetifierMore)
        self.tableView.dataSource = self
        self.tableView.delegate = self
//        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false);
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.estimatedRowHeight = 44.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;

        self.tableView.tableFooterView = UIView()
        
        self.attachCollection()
        self.configureStateMachine()
        self.refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func attachCollection() {
        self.detachCollection()
        
        if let collection = self.collection {
            let events = collection.getEventManager()
            events.listenTo("sync", action: {
                let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, delta)
                
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.endLoading(true, error: nil)
                })
            })
            
            events.listenTo("add", action: {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    self.endLoading(true, error: nil)
                }
            })
            
            events.listenTo("error", action: { (err:Any?) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.endLoading(true, error: err as? NSError, completion: nil)
                }
            })
        }
    }
    
    func detachCollection() {
        if let collection = self.collection {
            let events = collection.getEventManager()
            events.removeListeners("sync")
            events.removeListeners("error")
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //self.detachCollection()
    }
    
    func ifNeedMore(collection: CollectionProtocol, indexPath: NSIndexPath) -> Bool {
        return collection.ifNeedMore() && indexPath.row == collection.getCount()
    }
    
    func hasContent() -> Bool {
        if collection != nil {
            return collection!.getCount() > 0
        }
        
        return true
    }
    
    func refresh() {
        if (currentState == .Loading) { return }
        
        if let collection = self.collection {
            self.startLoading(true)
            collection.fetch()
        }
    }
    
    func configureStateMachine() {
        loadingView = LoadingView(frame: view.frame)
        emptyView = EmptyView(frame: view.frame)
        let failureView = ErrorView(frame: view.frame)
        failureView.tapGestureRecognizer.addTarget(self, action: Selector("refresh"))
        errorView = failureView
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    func setupViews() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapGoBack")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
    }
    
    func didTapGoBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}

extension MyCollectionTableView: UITableViewDelegate {
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.ifNeedMore(collection!, indexPath: indexPath) {
            return 60
        }
        
        return 110
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, customDidSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.ifNeedMore(collection!, indexPath: indexPath) {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! MoreViewCell
            cell.startLoading()
            collection!.more()
            //self.tableView.reloadData()
        } else {
            self.tableView(tableView, customDidSelectRowAtIndexPath: indexPath)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

extension MyCollectionTableView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if collection!.ifNeedMore() {
            return collection!.getCount() + 1
        }
        
        return collection!.getCount()
    }
    
    func tableView(tableView: UITableView, customcellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIndetifier())
        
        return cell!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if collection!.ifNeedMore() && indexPath.row == collection!.getCount() {
            let cellMore = tableView.dequeueReusableCellWithIdentifier(reuseIndetifierMore) as! MoreViewCell
            cellMore.prepareView(collection!)
            cellMore.separatorInset = UIEdgeInsetsMake(0, 2000, 0, 0);
            return cellMore
        }
        
        return self.tableView(tableView, customcellForRowAtIndexPath: indexPath);
    }
}
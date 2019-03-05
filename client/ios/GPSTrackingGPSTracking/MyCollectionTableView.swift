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
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("refresh"), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
        
        // Do any additional setup after loading the view.
        self.tableView.registerNib(UINib(nibName: nibViewCell(), bundle: nil),
            forCellReuseIdentifier: reuseIndetifier())
        
        self.tableView.registerNib(UINib(nibName: "MoreViewCell", bundle: nil), forCellReuseIdentifier: reuseIndetifierMore)
        
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
        
        if collection != nil {
            let events = collection!.getEventManager()
            events.listenTo("sync", action: {
                var delta: Int64 = 1 * Int64(NSEC_PER_SEC)
                var time = dispatch_time(DISPATCH_TIME_NOW, delta)
                
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.endLoading(animated: true, error: nil)
                })
            })
            
            events.listenTo("error", action: { (err:Any?) in
                self.endLoading(animated: true, error: err as? NSError, completion: nil)
            })
        }
    }
    
    func detachCollection() {
        if collection != nil {
            let events = collection!.getEventManager()
            events.removeListeners("sync")
            events.removeListeners("error")
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.detachCollection()
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
        
        self.startLoading(animated: true)
        
        if collection != nil {
            collection!.fetch()
        }
        
        self.refreshControl!.endRefreshing()
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: UIBarButtonItemStyle.Done, target: self, action: "didTapGoBack")
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.new()
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
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIndetifier()) as! UITableViewCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if collection!.ifNeedMore() && indexPath.row == collection!.getCount() {
            let cellMore: MoreViewCell  = tableView.dequeueReusableCellWithIdentifier(reuseIndetifierMore) as! MoreViewCell
            cellMore.prepareView(collection!)
            cellMore.separatorInset = UIEdgeInsetsMake(0, cellMore.bounds.size.width, 0, 0);
            return cellMore
        }
        
        return self.tableView(tableView, customcellForRowAtIndexPath: indexPath);
    }
}
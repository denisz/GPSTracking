//
//  AppViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/26/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

let KEY_EVENT_POPUP_EVENT   = "popupEvent"
let KEY_EVENT_EVENT         = "viewEvent"
let KEY_EVENT_ANSWER        = "viewAnswer"
let KEY_ENTER_APP           = "enterToApp"
let KEY_REMOVE_EVENT        = "removeEvent"

var BLOCKING_EVENT_POPUP: Bool = false

class AppViewController : UIViewController, UIAlertViewDelegate {
    @IBOutlet weak var mapController: MyMapViewController?
    var mainController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        unsetup()
        Dispatcher.sharedInstance.events.listenTo(KEY_EVENT_POPUP_EVENT, action: performViewPopupEvent)
        Dispatcher.sharedInstance.events.listenTo(KEY_EVENT_EVENT, action: performViewEvent)
        Dispatcher.sharedInstance.events.listenTo(KEY_EVENT_ANSWER, action: performViewAnswer)
        
        Dispatcher.sharedInstance.events.trigger(KEY_ENTER_APP, information: nil)
        Dispatcher.sharedInstance.events.removeListeners(KEY_ENTER_APP)
    }
    
    func unsetup() {
        Dispatcher.sharedInstance.events.removeListeners(KEY_EVENT_POPUP_EVENT)
        Dispatcher.sharedInstance.events.removeListeners(KEY_EVENT_EVENT)
        Dispatcher.sharedInstance.events.removeListeners(KEY_EVENT_ANSWER)
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    func dismissAppViewController(cb: () -> Void) {
        if let controller = self.presentedViewController {
            controller.dismissViewControllerAnimated(true, completion: cb)
        } else {
            cb()
        }
    }
    
    func performViewEvent(eventData: Any?) {
        let model = eventData as! Event
        
        let requestViewController: MyNavigationController = UIStoryboard(name: "Request", bundle: nil).instantiateViewControllerWithIdentifier("requestController") as! MyNavigationController
        
        let rvc = requestViewController.visibleViewController as! RequestViewController
        rvc.loadModel(model)
        rvc.showBtnBack()
        
        let answer = model.getLink("answer") as? Answer;
        
        if (answer != nil) {
            rvc.loadModel(answer!)
        }

        self.dismissAppViewController { () -> Void in
            self.presentViewController(requestViewController, animated: true) {
                print("presenting view controller - done")
            }
        }
    }
    
    func performViewAnswer(eventData: Any?) {
        let model = eventData as! Event
        let answerViewController = NewAnswerView.create(model);
        self.presentViewController(answerViewController, animated: true) {}
    }
    
    func performViewPopupEvent(eventData: Any?) {
        let event_id = eventData as! String
        let model = Event.withUserAndAnswer(event_id)
        
        if BLOCKING_EVENT_POPUP == false {
            AnswerPopupViewController.presentActionSheetView(model)
        } else {
            model.events.listenTo("sync", action: {
                MapSupport.sharedInstance.addPoint(model)
            })
            
            model.fetchIfNeeded()
        }
    }
    
    @IBAction func showProfile() {
        let profileController: MyNavigationController! = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("profileController") as! MyNavigationController
        
        let pvc = profileController.visibleViewController as? ProfileViewController;
        pvc!.loadModel(ServerRestApi.sharedInstance.getUser()!.copy())
        pvc!.showBtnBack()
        
        self.presentViewController(profileController, animated: true, completion: nil)
    }
    
    @IBAction func showArchive() {
        let archiveController: UIViewController! = UIStoryboard(name: "Archive", bundle: nil).instantiateViewControllerWithIdentifier("archiveController")
        
        self.presentViewController(archiveController, animated: true, completion: nil)
    }
    
    @IBAction func showRequests() {
        let myPerformRequests: UIViewController! = UIStoryboard(name: "MyPerformRequestsViewController", bundle: nil).instantiateViewControllerWithIdentifier("myPerformRequests")

        self.presentViewController(myPerformRequests, animated: true, completion: nil)
    }
    
    @IBAction func didTapUserLocation() {
        Dispatcher.sharedInstance.events.trigger(KEY_EVENT_USER_LOCATION, information: nil)
    }
    
    @IBAction func showRequest() {
        let newRequestController: UIViewController! = UIStoryboard(name: "NewRequest", bundle: nil).instantiateViewControllerWithIdentifier("newRequestController")

        BLOCKING_EVENT_POPUP = true
        self.presentViewController(newRequestController, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .Default
    }
}
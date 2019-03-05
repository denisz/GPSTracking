//
//  RequestVieController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/9/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import StatefulViewController

protocol EditableRequestController {
    func didTapEdit()
}

class RequestViewController: StatefulViewController, StatefulViewControllerDelegate, CAPSPageMenuDelegate {
    var model: Event?
    var modelId: String?
    var modelAnswer: Answer?
    var modelUser: User?
    var controllerArray: [UIViewController]?
    var pageMenu: CAPSPageMenu?
    var currentContoller: UIViewController?
    
    func hasContent() -> Bool {
        if model != nil {
            return model!.isSync()
        }
        
        return false
    }
    
    func handleErrorWhenContentAvailable(error: NSError) {
        let alertController = UIAlertController(title: "Ooops", message: "Something went wrong.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let ctrls = self.controllerArray {
            for ctrl in ctrls {
                ctrl.viewWillAppear(animated)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model!.events.listenTo("sync", action: {
            var delta: Int64 = 1 * Int64(NSEC_PER_SEC)
            var time = dispatch_time(DISPATCH_TIME_NOW, delta)
            
            dispatch_after(time, dispatch_get_main_queue(), {
                //проверить если мы еще на экране
                self.configureView()
                self.endLoading(animated: true, error: nil)
            })
        })
        
        model!.events.listenTo("error", action: { (err: Any?) in
            self.endLoading(animated: true, error: err as? NSError)
        })
        
        self.configureStateMachine()
        self.configureNavigationController()
        
        refresh()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if model != nil {
            model!.events.removeListeners("sync")
            model!.events.removeListeners("error")
        }
    }
    
    func configureStateMachine() {
        loadingView = LoadingView(frame: view.frame)
        emptyView = EmptyView(frame: view.frame)
        let failureView = ErrorView(frame: view.frame)
        failureView.tapGestureRecognizer.addTarget(self, action: Selector("refresh"))
        errorView = failureView
    }
    
    func refresh() {
        if (currentState == .Loading) { return }
        
        self.startLoading(animated: true)
        self.model!.fetchIfNeeded();
    }
    
    func configureNavigationController() {
        self.title = "Запрос"
        
        if let nc = self.navigationController {
            nc.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            nc.navigationBar.barStyle = UIBarStyle.Default
            nc.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
            nc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)]
        }
    }
    
    func configureView() {
        if let nc = self.navigationController {
            controllerArray = []
            
            var requestInfo: RequestInfoViewController = RequestInfoViewController(nibName: "RequestInfoViewController", bundle: nil)
            requestInfo.title = "Главная"
            requestInfo.mainViewController = self;
            requestInfo.parentNavigationController = nc;
            requestInfo.model     = model
            
            controllerArray!.append(requestInfo)
            
            if model!.isOwnerCurrentUser() {
                var requestAnswers: RequestAnswerViewController = RequestAnswerViewController(nibName: "RequestAnswerViewController", bundle: nil)
                requestAnswers.parentNavigationController = nc
                requestAnswers.model = model
                requestAnswers.title = "Ответы"
                controllerArray!.append(requestAnswers)
            } else {
                if (modelAnswer == nil || !modelAnswer!.isSync()) {
                    //если ответа нету показываем данную view
                    var requestGuestAnswers: RequestAnswerGuestViewController = RequestAnswerGuestViewController(nibName: "RequestAnswerGuestViewController", bundle: nil)
                    requestGuestAnswers.parentNavigationController = nc
                    requestGuestAnswers.model = model
                    requestGuestAnswers.modelUser = ServerRestApi.sharedInstance.getUser()!
                    requestGuestAnswers.title = "Ответ"
                    controllerArray!.append(requestGuestAnswers)
                } else {
                    let requestViewController: MyNavigationController = UIStoryboard(name: "Answer", bundle: nil).instantiateViewControllerWithIdentifier("answerController") as! MyNavigationController
                    
                    var avc = requestViewController.visibleViewController as! AnswerViewController
                    avc.parentNavigationController = nc
                    avc.loadModel(modelAnswer!)//загружаем модель с ответом
                    avc.loadModel(ServerRestApi.sharedInstance.getUser()!)//загружаем пользователя
                    avc.title = "Ответ"
                    controllerArray!.append(avc)
                }
            }
            
            var parameters: [String: AnyObject] = ["menuItemSeparatorWidth": 4.3,
                "scrollMenuBackgroundColor": UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0),
                "viewBackgroundColor": UIColor.whiteColor(),
                
                "bottomMenuHairlineColor": UIColor(red:0.72, green:0.72, blue:0.72, alpha:1),
                //            UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1),
                "selectionIndicatorColor": UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 0.0),
                "selectedMenuItemLabelColor": UIColor(red:0.9, green:0.31, blue:0.19, alpha:1),
                "unselectedMenuItemLabelColor": UIColor(red:0.55, green:0.58, blue:0.6, alpha:1),
                "menuItemFont": UIFont(name: "HelveticaNeue-Medium", size: 14.0)!,
                "menuHeight": 40.0,
                "menuItemWidth": 90.0,
                "centerMenuItems": true
            ]
            
            // Initialize scroll menu
            pageMenu = CAPSPageMenu(viewControllers: controllerArray!, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), options: parameters)
            
            self.currentContoller = controllerArray!.first;
            
            pageMenu?.delegate = self;
            
            self.view.addSubview(pageMenu!.view)
        }
    }
    
    func didTapEdit() {
    }
    
    func didTapBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func didTapGoToLeft() {
        var currentIndex = pageMenu!.currentPageIndex
        
        if currentIndex > 0 {
            pageMenu!.moveToPage(currentIndex - 1)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    func willMoveToPage(controller: UIViewController, index: Int) {
        pageMenu?.view.userInteractionEnabled = false
    }
    
    func didMoveToPage(controller: UIViewController, index: Int) {
        self.currentContoller = controller
        pageMenu?.view.userInteractionEnabled = true
    }
    
    func goToAnswer() {
        pageMenu!.moveToPage(pageMenu!.controllerArray.count - 1)
        pageMenu?.view.userInteractionEnabled = true
    }
    
    func didTapGoToRight() {
        var currentIndex = pageMenu!.currentPageIndex
        
        if currentIndex < pageMenu!.controllerArray.count {
            pageMenu!.moveToPage(currentIndex + 1)
        }
    }
    
    func showBtnBack() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: UIBarButtonItemStyle.Done, target: self, action: "didTapBack")
    }
    
    func loadModel(model: Event) {
        self.model          = model
        self.modelAnswer    = model.getLink("answer")   as? Answer
        self.modelUser      = model.getLink("user")     as? User
    }
    
    func loadModel(model: Answer) {
        self.modelAnswer = model
    }
    
    func loadModel(model: User) {
        self.modelUser = model
    }
    
    func loadModel(id: String) {
        self.modelId = id
    }
}



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
import MXSegmentedPager
import CoreMotion

protocol EditableRequestController {
    func didTapEdit()
}

class RequestViewController: StatefulViewController, StatefulViewControllerDelegate {
    var model               : Event?
    var modelId             : String?
    var modelAnswer         : Answer?
    var modelUser           : User?
    var controllerArray     : [UIViewController]?
    var segmentedPager      : MXSegmentedPager?
    var currentContoller    : UIViewController?
    
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
            let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, delta)
            
            dispatch_after(time, dispatch_get_main_queue(), {
                //проверить если мы еще на экране
                self.configureView()
                self.endLoading(true, error: nil)
            })
        })
        
        model!.events.listenTo("error", action: { (err: Any?) in
            self.endLoading(true, error: err as? NSError)
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
        
        self.startLoading(true)
        self.model!.fetchIfNeeded();
    }
    
    func configureNavigationController() {
        if let nc = self.navigationController {
            nc.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            nc.navigationBar.barStyle = UIBarStyle.Default
            nc.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
        }
    }
    
    func setupControllers() {
        let nc = self.navigationController
        
        controllerArray = []
        
        let requestInfo: RequestInfoViewController = RequestInfoViewController(nibName: "RequestInfoViewController", bundle: nil)
        requestInfo.title = "Главная".localized
        requestInfo.model = model
        requestInfo.mainViewController = self;
        requestInfo.parentNavigationController = nc;

        controllerArray!.append(requestInfo)
        
        if model!.isOwnerCurrentUser() {
            //список ответов
            let requestAnswers: RequestAnswerViewController = RequestAnswerViewController(nibName: "RequestAnswerViewController", bundle: nil)
            requestAnswers.parentNavigationController = nc
            requestAnswers.model = model
            requestAnswers.title = "Ответы".localized
            controllerArray!.append(requestAnswers)
            
            if (model!.withSpectators()) {
                let requests: RequestsViewController = UIStoryboard(name: "RequestsViewController", bundle: nil).instantiateViewControllerWithIdentifier("requestsViewController") as! RequestsViewController
                
                requests.title = "Очевидцы".localized
                requests.collection = model!.collectionSpectartor()
                requests.parentNavigationController = nc
                controllerArray!.append(requests)
            }
        } else {
            if (modelAnswer == nil || !modelAnswer!.isSync()) {
                //если ответа нету, показываем данную view
                let newAnswerView = NewAnswerView()
                newAnswerView.model = model
                newAnswerView.title = "Ответ".localized
                newAnswerView.buttonSend = true
                newAnswerView.authorField = false
                newAnswerView.contextField = false
                newAnswerView.subtypeField = false
                newAnswerView.delegate = self
                newAnswerView.parentNavigationController = nc

                controllerArray!.append(newAnswerView)
            } else {
                //показываем ответ с комментариями
                let avc = UIStoryboard(name: "FastAnswerViewController", bundle: nil).instantiateViewControllerWithIdentifier("FastAnswerViewController") as! FastAnswerViewController
                
                avc.parentNavigationController = nc
                avc.loadModel(modelAnswer!)
                avc.loadModel(ServerRestApi.sharedInstance.getUser()!)
                avc.title = "Ответ".localized
                
                controllerArray!.append(avc)
            }
        }
    }
    
    func configureView() {
        if let _ = self.navigationController {
            controllerArray = []
            
            if self.model!.isOwnerCurrentUser() {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Изменить".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapEdit")
            }
            
            setupControllers()
            
            segmentedPager = MXSegmentedPager()
            segmentedPager!.delegate = self
            segmentedPager!.dataSource = self
            
            view.backgroundColor = UIColor.whiteColor();
            view.addSubview(segmentedPager!)
            
            segmentedPager!.minimumHeaderHeight = 0
//            segmentedPager!.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
            segmentedPager!.segmentedControl.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            segmentedPager!.segmentedControl.titleTextAttributes = [
                NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 14.0)!,
                NSForegroundColorAttributeName: UIColor(red:0.55, green:0.58, blue:0.6, alpha:1)
            ]
            segmentedPager!.segmentedControl.selectedTitleTextAttributes = [
                NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 14.0)!,
                NSForegroundColorAttributeName: UIColor(red:0.9, green:0.31, blue:0.19, alpha:1)
            ]
            segmentedPager!.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
            segmentedPager!.segmentedControl.selectionIndicatorColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 0.0)
            segmentedPager!.segmentedControl.borderColor = UIColor(red:0.72, green:0.72, blue:0.72, alpha:1)
            segmentedPager!.segmentedControl.borderWidth = 0.5
            segmentedPager!.segmentedControl.borderType = HMSegmentedControlBorderType.Bottom
            
            segmentedPager!.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
        }
    }
    
    func didTapEdit() {
    }
    
    func didTapBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func goToAnswer() {
        self.segmentedPager!.scrollToPageAtIndex(1, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    func showBtnBack() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapBack")
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


extension RequestViewController: MXSegmentedPagerDelegate, MXSegmentedPagerDataSource {
    func heightForSegmentedControlInSegmentedPager(segmentedPager: MXSegmentedPager!) -> CGFloat {
        return 40
    }
    
    func numberOfPagesInSegmentedPager(segmentedPager: MXSegmentedPager!) -> Int {
        return controllerArray!.count
    }
    
    func segmentedPager(segmentedPager: MXSegmentedPager!, viewForPageAtIndex index: Int) -> UIView! {
        return controllerArray![index].view
    }
    
    func segmentedPager(segmentedPager: MXSegmentedPager!, titleForSectionAtIndex index: Int) -> String! {
        return controllerArray![index].title
    }
}

extension RequestViewController: NewAnswerViewDelegate {
    func newAnswerView(answerView: UIViewController, withAnswer answer: Answer) {
        //сделать замену
        if let nc = self.navigationController {
            let avc = UIStoryboard(name: "FastAnswerViewController", bundle: nil).instantiateViewControllerWithIdentifier("FastAnswerViewController") as! FastAnswerViewController
            
            avc.parentNavigationController = nc
            avc.loadModel(answer)
            avc.loadModel(ServerRestApi.sharedInstance.getUser()!)
            avc.title = "Ответ".localized

            self.controllerArray!.removeAtIndex(1)
            self.controllerArray!.append(avc)
            self.segmentedPager?.reloadData()
        }
    }
}



//
//  TestViewController.swift
//  NFTopMenuController
//
//  Created by Niklas Fahl on 12/16/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

import UIKit
import XLForm
import MXSegmentedPager
import StatefulViewController

//todo add loader
class ProfileViewController: StatefulViewController, StatefulViewControllerDelegate, MXSegmentedPagerDelegate, MXSegmentedPagerDataSource {
    
    var controllerArray     : [UIViewController]?
    var cover               : UIView?
    var segmentedPager      : MXSegmentedPager?
    var model               : User?
    var modelId             : String?
    
    func hasContent() -> Bool
    {
        if model != nil {
            return model!.isSync()
        }
        
        return false
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
        self.model!.fetch();
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
                self.configureView()
                self.endLoading(true, error: nil)
            })
        })
        
        model!.events.listenTo("error", action: { (err: Any?) in
            print("error loading profile")
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
    
    func configureNavigationController() {
        if let nc = self.navigationController {
            nc.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            nc.navigationBar.barStyle = UIBarStyle.Default
            nc.navigationBar.tintColor = UIColor(red:0.28, green:0.31, blue:0.32, alpha:1)
        }
    }
    
    func configureView() {
        if let _ = self.navigationController {
            controllerArray = []
            
            setupControllers()
            setupCover()
            
            segmentedPager = MXSegmentedPager()
            segmentedPager!.delegate = self
            segmentedPager!.dataSource = self
            
            view.backgroundColor = UIColor.whiteColor();
            view.addSubview(segmentedPager!)
            
            segmentedPager!.setParallaxHeaderView(cover, mode: VGParallaxHeaderMode.Fill, height: 200)
            segmentedPager!.minimumHeaderHeight = 0
            segmentedPager!.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
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
    
    func setupCover() {
        let profileInfoView: ProfileInfoView = ProfileInfoView()
        
        profileInfoView.loadModel(model!)
        profileInfoView.parentViewController = self
        profileInfoView.parentNavigationController = self.navigationController!
        
        cover = profileInfoView
    }
    
    func setupControllers() {
        if model!.isCurrentUser() {
            setupCurrentUserControllers()
        } else {
            setupGuestControllers()
        }
    }
    
    func setupGuestControllers() {
        let activeRequests: RequestsViewController = UIStoryboard(name: "RequestsViewController", bundle: nil).instantiateViewControllerWithIdentifier("requestsViewController") as! RequestsViewController
        
        activeRequests.title = "Активные".localized
        activeRequests.collection = model?.collectionEvents()
        activeRequests.parentNavigationController = self.navigationController!
        
        controllerArray!.append(activeRequests)
    }
    
    func setupCurrentUserControllers() {
        let activeRequests: RequestsViewController = UIStoryboard(name: "RequestsViewController", bundle: nil).instantiateViewControllerWithIdentifier("requestsViewController") as! RequestsViewController
        
        activeRequests.title = "Активные".localized
        activeRequests.collection = model?.collectionMyActive()
        activeRequests.parentNavigationController = self.navigationController!
        
        controllerArray!.append(activeRequests)

        let cancelledRequests: RequestsViewController = UIStoryboard(name: "RequestsViewController", bundle: nil).instantiateViewControllerWithIdentifier("requestsViewController") as! RequestsViewController
        
        cancelledRequests.title = "Отмененные".localized
        cancelledRequests.collection = model?.collectionMyCanceled()
        cancelledRequests.parentNavigationController = self.navigationController!
        
        controllerArray!.append(cancelledRequests)
        
        let favoritesRequests: RequestsViewController = UIStoryboard(name: "RequestsViewController", bundle: nil).instantiateViewControllerWithIdentifier("requestsViewController") as! RequestsViewController
        
        favoritesRequests.title = "Избранное".localized
        favoritesRequests.collection = model?.collectionMyFavorites()
        favoritesRequests.parentNavigationController = self.navigationController!
        
        controllerArray!.append(favoritesRequests)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
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
    
    func didTapBack() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func showBtnBack() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "didTapBack")
    }

    func loadModel(model: User) {
        self.model = model
    }
    
    func loadModel(id: String) {
        self.modelId = id
        self.model = User()
    }
}
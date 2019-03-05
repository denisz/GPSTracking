//
//  AnswerPopupView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/15/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher


class AnswerPopupView: UIView {
    var model: Event?
    var loadingView: UIView?
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var context: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var locationView: UILabel!
    @IBOutlet weak var mapView: RequestMapView!
    
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "AnswerPopupView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func setModel(model: Event) {
        self.model = model
        
        self.model!.events.listenTo("sync", action: {
            let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, delta)
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.endLoading()
                self.configureView()
                //добавляем в список
                MapSupport.sharedInstance.addPoint(self.model!)
            })
        })
        
        self.model!.events.listenTo("error", action: { (err: Any?) in
        })
        
        self.model!.fetchIfNeeded()
        
        startLoading()
    }
    
    func startLoading() {
        self.loadingView = LoadingView(frame: self.frame)
        self.addSubview(self.loadingView!)
    }
    
    func endLoading() {
        self.loadingView!.alpha = 1
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.loadingView!.alpha = 0
        }) { (_) -> Void in
            self.loadingView!.removeFromSuperview()
            self.loadingView = nil
        }
    }
    
    func configureView() {
        prepareEventView(model!)
        
        let user = model!.getLink("user") as? User
        if user != nil {
            prepareUserView(user!)
        }
    }
    
    func prepareEventView(model: Event) {
        let localizedLocation   = model.localizedLocation
        let localizedContext    = model.combineContext
        
//        var distance = GMSGeometryDistance(model.location().coordinate, LocationCore.sharedInstance.lastLocation!.coordinate)
//        
//        println("distance \(distance)")
        
        self.dateView.text = AppHelp.formatDate(model.createdAt)
        self.context.text  = localizedContext
        self.locationView.text     = localizedLocation
        self.mapView.setModel(model)
    }
    
    func prepareUserView(model: User) {
        self.fullname.text = model.fullname()
        self.avatar.kf_setImageWithURL(model.absolutePathForAvatar())
    }
}

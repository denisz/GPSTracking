//
//  RadarViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/11/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import LTMorphingLabel
import pop
import Dollar

class RadarViewController: UIViewController {
    @IBOutlet weak var labelView: LTMorphingLabel?
    @IBOutlet weak var marker1View: UIImageView?
    @IBOutlet weak var marker2View: UIImageView?
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopMarkerAnimationTimer()
    }
    
    func setupLocationCore(function: () -> ()?) {
        LocationCore.sharedInstance.fullControlWay()
        function()
    }
    
    func setupTimeout(function: () -> ()?) {
        let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), {
            function()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func start() {
        let completeCallback = $.after(2) {
            self.goToApp()
        }
        
        self.startMarkerAnimationTimer()
        self.setupRadar()
        
        PermissionsHelper.checkLocation({
            dispatch_async(dispatch_get_main_queue(), {
                self.setupLocationCore(completeCallback)
                self.setupTimeout(completeCallback)
            })
        })
    }
    
    func setupRadar() {
        self.labelView!.morphingEffect = .Evaporate
        _ = [
            "Подготовка профиля",
            "Определение местоположения"
        ];
        
        self.labelView!.text = "Определение местоположения"
    }
    
    func startMarkerAnimationTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target:self, selector: "timerDidAnimMarker:", userInfo: nil, repeats: true)
    }

    func stopMarkerAnimationTimer() {
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    @objc func timerDidAnimMarker(timer: NSTimer) {
        let springAnimation1 = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        springAnimation1.toValue = NSValue(CGPoint: CGPointMake(0.9, 0.9))
        springAnimation1.velocity = NSValue(CGPoint: CGPointMake(2, 2))
        springAnimation1.autoreverses = true
        springAnimation1.springBounciness = 25
        springAnimation1.springSpeed = 10
        
        let springAnimation2 = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        springAnimation2.toValue = NSValue(CGPoint: CGPointMake(0.9, 0.9))
        springAnimation2.velocity = NSValue(CGPoint: CGPointMake(2, 2))
        springAnimation2.autoreverses = true
        springAnimation2.springBounciness = 20
        springAnimation2.springSpeed = 20


        self.marker1View!.pop_addAnimation(springAnimation1, forKey: "springAnimation")
        self.marker2View!.pop_addAnimation(springAnimation2, forKey: "springAnimation")
    }
    
    func goToApp() {
        let appViewController = UIStoryboard(name: "App", bundle: nil).instantiateViewControllerWithIdentifier("Main App View Controller") as! AppViewController
        self.presentViewController(appViewController, animated: true, completion: nil);
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .LightContent
    }
}
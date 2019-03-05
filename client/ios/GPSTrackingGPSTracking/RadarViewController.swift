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

class RadarViewController: UIViewController {
    @IBOutlet var labelView: LTMorphingLabel?
    @IBOutlet var marker1View: UIImageView?
    @IBOutlet var marker2View: UIImageView?
    
    var timer: NSTimer?
    
    var appViewController: UIViewController! = UIStoryboard(name: "App", bundle: nil).instantiateViewControllerWithIdentifier("Main App View Controller") as! UIViewController

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopMarkerAnimationTimer()
    }
    
    func setupLocationCore(function: () -> ()?) {
        LocationCore.sharedInstance.WhereAmILocation({(lat: CLLocationDegrees, loc: CLLocationDegrees, acc: CLLocationAccuracy) -> Void in
            function()
            LocationCore.sharedInstance.fullControlWay()
        })
    }
    
    func setupTimeout(function: () -> ()?) {
        var delta: Int64 = 3 * Int64(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), {
            function()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        var completeCallback = $.after(2) {
            self.goToApp()
        }

        self.startMarkerAnimationTimer()
        self.setupRadar()
        self.setupLocationCore(completeCallback)
        self.setupTimeout(completeCallback)
    }
    
    func setupRadar() {
        self.labelView!.morphingEffect = .Evaporate
        var words = [
            "Подготовка профиля",
            "Поиск местоположение"
        ];
        
        self.labelView!.text = "Поиск местоположение"
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
        self.presentViewController(self.appViewController, animated: true, completion: nil);
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle  {
        return .LightContent
    }
}
//
//  ProfileInfoViewController.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/9/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit


class ProfileInfoViewController: UIViewController {
    var model: User?
    var parentNavigationController: UINavigationController?
    
    @IBOutlet var buttonSpeech: UIButton?
    @IBOutlet var buttonSettings: UIButton?
    @IBOutlet var avatar: UIImageView?
    @IBOutlet var fullname: UILabel?
    @IBOutlet var location: UILabel?
    
    override func viewDidLoad() {
        setupView()
        
        var gestureSettings = UITapGestureRecognizer(target: self, action: "didTapSettings:")
        buttonSettings!.addGestureRecognizer(gestureSettings)
        
        var gestureSpeech = UITapGestureRecognizer(target: self, action: "didTapSpeech:")
        buttonSpeech!.addGestureRecognizer(gestureSpeech)

        var gestureAvatar = UITapGestureRecognizer(target: self, action: "didTapAvatar:")
        avatar!.addGestureRecognizer(gestureAvatar)
        
        super.viewDidLoad()
    }
    
    func setupView() {
        fullname!.text = model!.fullname()
        buttonSettings!.hidden = !model!.isCurrentUser()
    }
    
    func didTapSettings(sender:UIButton!) {
        println("settings");
//        let settingsController: UIViewController! = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("settingsController") as! UIViewController
//        
//        self.parentNavigationController!.pushViewController(settingsController, animated: true)
    }
    
    func didTapSpeech(sender: UITapGestureRecognizer) {
        //открыть комментариий
        println("speech")
    
    }
    
    func didTapAvatar(sender: UITapGestureRecognizer) {
        println("avatar")
    }
}
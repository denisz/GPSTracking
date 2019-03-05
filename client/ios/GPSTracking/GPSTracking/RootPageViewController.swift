//
//  RootPageViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

//подумать, зачем все это висит???
class RootPageViewController : UIPageViewController {
    
    let loginView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Login View") 
    
    let enterPhoneNumberView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Enter Phone View")
    
    let enterCodeView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Enter Code View")
    
    let registerView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Register View")
    
    var appViewController: UIViewController! = UIStoryboard(name: "App", bundle: nil).instantiateViewControllerWithIdentifier("App View Controller")
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        view.backgroundColor = UIColor.whiteColor()
        
        setViewControllers([loginView], direction: .Forward, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func exitToApp() {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            AppHelp.presentAppView()
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }

    @IBAction func forwardToEnterPhoneNumber() {
        setViewControllers([enterPhoneNumberView], direction: .Forward, animated: true, completion: nil)
    }
    
    @IBAction func forwardToEnterCode() {
        setViewControllers([enterCodeView], direction: .Forward, animated: true, completion: nil)
    }
    
    @IBAction func forwardToLogin() {
        setViewControllers([loginView], direction: .Forward, animated: true, completion: nil)
    }

    @IBAction func forwardToRegister() {
        setViewControllers([registerView], direction: .Forward, animated: true, completion: nil)
    }
    
    @IBAction func reverseToEnterPhoneNumber() {
        setViewControllers([enterPhoneNumberView], direction: .Reverse , animated: true, completion: nil)
    }
    
    @IBAction func reverseToEnterCode() {
        setViewControllers([enterCodeView], direction: .Reverse, animated: true, completion: nil)
    }
    
    @IBAction func reverseToLogin() {
        setViewControllers([loginView], direction: .Reverse, animated: true, completion: nil)
    }
    
    @IBAction func reverseToRegister() {
        setViewControllers([registerView], direction: .Reverse, animated: true, completion: nil)
    }
}
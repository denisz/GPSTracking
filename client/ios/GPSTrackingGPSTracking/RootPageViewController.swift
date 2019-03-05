//
//  RootPageViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class RootPageViewController : UIPageViewController {
    
    let loginView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Login View") as! UIViewController
    
    let enterPhoneNumberView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Enter Phone View")as! UIViewController
    
    let enterCodeView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Enter Code View")as! UIViewController
    
    let registerView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Register View")as! UIViewController
    
    var appViewController: UIViewController! = UIStoryboard(name: "App", bundle: nil).instantiateViewControllerWithIdentifier("App View Controller") as! UIViewController
    
    let termsOfService: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Terms of Service View") as! UIViewController
    
    let permissionsView: UIViewController! = UIStoryboard(name: "Startup", bundle: nil).instantiateViewControllerWithIdentifier("Permissions View") as! UIViewController

    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        view.backgroundColor = UIColor.whiteColor()
        
        //тут в зависимости от пользователя загрузин нужную страницу
         setViewControllers([loginView], direction: .Forward, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func exitToApp() {
        var modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.CoverVertical;
        self.appViewController.modalTransitionStyle = modalStyle;
        self.presentViewController(self.appViewController, animated: true, completion: nil);
    }
    
    func showTermOfService() {
        var destinationViewController = self.termsOfService as! TermOfService;
        
        destinationViewController.modalTransitionStyle    = UIModalTransitionStyle.CrossDissolve;
        destinationViewController.modalPresentationStyle  = UIModalPresentationStyle.OverFullScreen;
        
        self.presentViewController(destinationViewController, animated: true, completion: nil);
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
    
    @IBAction func forwardToPermissions() {
        setViewControllers([permissionsView], direction: .Forward, animated: true, completion: nil)
    }
    
    @IBAction func reverseoPermissions() {
        setViewControllers([permissionsView], direction: .Reverse, animated: true, completion: nil)
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
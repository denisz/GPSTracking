//
//  LoginView.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/24/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import SwiftValidator
import SwiftyJSON
import RNLoadingButton

class LoginViewController : PageContentViewController, ValidationDelegate, UITextFieldDelegate{
    let validator = Validator()
    
    @IBOutlet weak var buttonLogin: RNLoadingButton?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var errorLabel: UILabel?
    @IBOutlet weak var loginFBView: UIView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var betweenLabelAndFormConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupValidator();
        setupViews();
    }
    
    func setupViews() {
        buttonLogin!.setActivityIndicatorAlignment(RNLoadingButtonAlignmentCenter)
        buttonLogin!.setActivityIndicatorStyle(UIActivityIndicatorViewStyle.Gray, forState: UIControlState.Disabled)
        buttonLogin!.hideTextWhenLoading = true
        
        passwordTextField?.delegate = self;
    }
    
    func determineContraints() -> [(CGFloat, CGFloat)] {
        return [ (80, 23), (15, -30) ]
    }
    
    override func updateConstraintKeyboard(hide: Bool, minY: CGFloat, maxY: CGFloat) {
        let constraints = determineContraints()
        if hide {
            self.topConstraint.constant = constraints[0].0
            self.betweenLabelAndFormConstraint.constant = constraints[1].0
        } else {
            self.topConstraint.constant = constraints[0].1
            self.betweenLabelAndFormConstraint.constant = constraints[1].1
        }
    }
    
    func setupValidator() {
        validator.registerField(emailTextField!, errorLabel: errorLabel!, rules: [RequiredRule(message: "Email"), EmailRule()])
        
        validator.registerField(passwordTextField!, errorLabel: errorLabel!, rules: [RequiredRule(message: "Password"), PasswordRule()])
    }
    
    @IBAction func loginHandle() {
        validator.validate(self);
    }
    
    func validationSuccessful() {
        let email = emailTextField!.text;
        let password = passwordTextField!.text;
        
        self.blockButton();
        
        //добавить крутилку
        
        ServerRestApi.sharedInstance.sendRequest(API.login(email!, password: password!))
            .responseSwiftyJSON({(req, res, json, err) in
                if (err != nil) {
                    self.handleInternetProblem(err!);
                } else {
                    if json["success"].number == 0 {
                        self.handleServerError(json);
                    } else {
                        self.handleServerSuccess(json);
                    }
                }
                
                self.unblockButton();
            });
    }
    
    func handleLoginFB() {
//        let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
//        loginWithSocialFB(fbAccessToken)
    }
    
    func loginWithSocialFB(access_token: String) {
        self.blockButton();
        
        //добавить крутилку
        ServerRestApi.sharedInstance.sendRequest(API.loginFB(access_token))
            .responseSwiftyJSON({(req, res, json, err) in
                if (err != nil) {
                    self.handleInternetProblem(err!);
                } else {
                    if json["success"].number == 0 {
                        self.handleServerError(json);
                    } else {
                        self.handleServerSuccess(json);
                    }
                }
                
                self.unblockButton();
            });
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        loginHandle()
        return true;
    }
    
    func blockButton() {
        buttonLogin!.loading = true;
        buttonLogin!.enabled = false;
    }
    
    func unblockButton() {
        buttonLogin!.loading = false;
        buttonLogin!.enabled = true;
    }
    
    func handleServerSuccess(json: SwiftyJSON.JSON) {
        let parentView = self.parentViewController as! RootPageViewController;
        parentView.exitToApp();
    }
    
    func handleServerError (json: SwiftyJSON.JSON) {
        let error = json["errCode"].string;
        errorLabel?.text  = error;
        errorLabel?.hidden = false;
    }
    
    func handleInternetProblem(error: NSError) {
        errorLabel?.text  = error.localizedDescription;
        errorLabel?.hidden = false;
    }
    
    func validationFailed(errors:[UITextField:ValidationError]) {
        // turn the fields to red
        for (_, error) in validator.errors {
            error.errorLabel?.text      = error.errorMessage // works if you added labels
            error.errorLabel?.hidden    = false
        }
    }
    
//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
//        if ((error) != nil) {
//            // Process error
//            println("Error")
//        } else if result.isCancelled {
//            // Handle cancellations
//            println("cancelled")
//        } else {
//            let fbToken = result.token.tokenString
//            let fbUserID = result.token.userID
//            println("Facebook login with user id \(fbUserID)")
//            self.loginWithSocialFB(fbToken)
//        }
//    }
//    
//    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
//    
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

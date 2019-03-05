//
//  RegisterViewController.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/25/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit
import SwiftValidator
import SwiftyJSON
import RNLoadingButton

class RegisterViewController : PageContentViewController, ValidationDelegate, UITextFieldDelegate {
    let validator = Validator();
    
    @IBOutlet weak var fullNameTextField : UITextField!;
    @IBOutlet weak var emailTextField : UITextField!;
    @IBOutlet weak var passwordTextField : UITextField!;
    @IBOutlet weak var errorLabel : UILabel!;
    @IBOutlet weak var buttonRegister: RNLoadingButton!
    @IBOutlet weak var termsOfServiceTextView : UITextView!;
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var betweenLabelAndFormConstraint: NSLayoutConstraint!
    @IBOutlet weak var betweenLabelsOne: NSLayoutConstraint!
    @IBOutlet weak var betweenLabelSecond: NSLayoutConstraint!
    @IBOutlet weak var betweenLabelsThird: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupValidator()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("showTermOfService"))
        
        termsOfServiceTextView!.addGestureRecognizer(gestureRecognizer)        
        setupViews()
    }
    
    func determineContraints() -> [(CGFloat, CGFloat)] {
        return [ (80, 23), (15, -45), (25, 25), (25, 25), (25, 25) ]
    }
    
    override func updateConstraintKeyboard(hide: Bool, minY: CGFloat, maxY: CGFloat) {
        let constraints = determineContraints()
        if hide {
            self.topConstraint.constant = constraints[0].0
            self.betweenLabelAndFormConstraint.constant = constraints[1].0
            
            self.betweenLabelsOne.constant   = constraints[2].0
            self.betweenLabelSecond.constant = constraints[3].0
            self.betweenLabelsThird.constant = constraints[4].0
            
        } else {
            self.topConstraint.constant = constraints[0].1
            self.betweenLabelAndFormConstraint.constant = constraints[1].1
            
            self.betweenLabelsOne.constant   = constraints[2].1
            self.betweenLabelSecond.constant = constraints[3].1
            self.betweenLabelsThird.constant = constraints[4].1

        }
    }
    
    func setupViews() {
        buttonRegister!.setActivityIndicatorAlignment(RNLoadingButtonAlignmentCenter)
        buttonRegister!.setActivityIndicatorStyle(UIActivityIndicatorViewStyle.Gray, forState: UIControlState.Disabled)
        buttonRegister!.hideTextWhenLoading = true
        
        fullNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    func setupValidator() {
        validator.registerField(emailTextField!, errorLabel: errorLabel!, rules: [RequiredRule(message: "Email"), EmailRule()])
        
        validator.registerField(passwordTextField!, errorLabel: errorLabel!, rules: [RequiredRule(message: "Password"), PasswordRule()])
        
        validator.registerField(fullNameTextField!, errorLabel: errorLabel!, rules: [RequiredRule(message: "Full Name"), FullNameRule()])

    }
    
    func validationSuccessful() {
        let fullname    = fullNameTextField!.text
        let email       = emailTextField!.text
        let password    = passwordTextField!.text
        
        let data = ["fullname" : fullname!, "email" : email!, "password" : password!]
        
        self.blockButton()
        
        ServerRestApi.sharedInstance.sendRequest(API.register(data))
            .responseSwiftyJSON({(req, res, json ,err) in
                // self.unblockButton()
                
//                return self.handleServerSuccess(json)
                
                if (err != nil) {
                    self.handleInternetProblem(err!)
                } else {
                    if (json["success"].number == 0) {
                        self.handleServerError(json)
                    } else {
                        self.handleServerSuccess(json)
                    }
                }
                
                self.unblockButton()
            });
    }
    
    func handleServerSuccess(json: SwiftyJSON.JSON) {
        let parentView = self.navigationController!.parentViewController as! RootPageViewController
            parentView.forwardToEnterPhoneNumber()
    }
    
    func blockButton() {
        buttonRegister!.loading = true
        buttonRegister!.enabled = false
    }
    
    func unblockButton() {
        buttonRegister!.loading = false
        buttonRegister!.enabled = true
    }
    
    func handleInternetProblem(error: NSError) {
        errorLabel?.text  = error.localizedDescription
        errorLabel?.hidden = false
        
        self.hideKeyboard()
    }
    
    func handleServerError (json: SwiftyJSON.JSON) {
        let error = json["errCode"].string
        errorLabel?.text  = error
        errorLabel?.hidden = false
        
        self.hideKeyboard()
    }
    
    func validationFailed(errors:[UITextField:ValidationError]) {
        // turn the fields to red
        for (_, error) in validator.errors {
            error.errorLabel?.text      = error.errorMessage // works if you added labels
            error.errorLabel?.hidden    = false
        }
        
        self.hideKeyboard()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        registerHandle()
        return true;
    }
    
    @IBAction func registerHandle() {
        validator.validate(self);
    }
    
    @IBAction func showTermOfService() {
        let termOfservice = TermOfServiceViewController()
        self.navigationController?.pushViewController(termOfservice, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }

}


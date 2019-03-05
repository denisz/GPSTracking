//
//  UIViewController+keyboard.swift
//  Think
//
//  Created by denis zaytcev on 8/6/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func setupKeyboard(autoHide: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShowNotification:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHideNotification:"), name: UIKeyboardWillHideNotification, object: nil)
        
        if autoHide == true {
            self.tapForHideKeyboard()
        }
    }
    
    func tapForHideKeyboard() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        gestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    func unsetupKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateLayoutConstraintWithNotification(notification)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateLayoutConstraintWithNotification(notification)
    }
    
    func topLayoutConstraint() -> NSLayoutConstraint? {
        return nil
    }
    
    func updateConstraintKeyboard(hide: Bool, minY: CGFloat, maxY: CGFloat) {
    }
    
    func updateLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntValue << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        let minY = CGRectGetMinY(convertedKeyboardEndFrame)
        let maxY = CGRectGetMaxY(view.bounds)
        
        self.updateConstraintKeyboard(minY == maxY, minY: minY, maxY: maxY)
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState.union(animationCurve), animations: {
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
}
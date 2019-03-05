//
//  StartupTextField.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 4/25/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class StartupTextField: UITextField, UITextFieldDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 0
        self.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
        setupPlaceholderColor(self, color: UIColor.whiteColor())
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        setupBorder(self, color: UIColor.whiteColor())
    }
    
    func setupBorder(textField : UITextField, color : UIColor) {
        let border = CALayer()
        let thickness = CGFloat(1.0)
        
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, CGRectGetWidth(self.frame), thickness)

        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func setupPlaceholderColor (textField : UITextField, color : UIColor) {
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [
            NSForegroundColorAttributeName  : UIColor.whiteColor(),
            ])
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField){
        self.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().postNotificationName("firstResponder", object: self)
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool{
        return true
    }
}
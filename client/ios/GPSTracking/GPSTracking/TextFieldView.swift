//
//  TextFieldView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/29/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

protocol TextFieldViewDelegate {
    func textField(textField: UITextField, handlerAttach button: UIButton )
    func textField(textField: UITextField, handlerSend button: UIButton, text: String )
}

class TextFieldView: UIView, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var buttonAttach: UIButton!
    @IBOutlet weak var buttonSend: UIButton!
    
    var delegate: TextFieldViewDelegate?;
    
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setupGesture()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
        setupGesture()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "TextFieldView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let text = self.textField.text
        self.textField.text = ""
        if !text!.isEmpty {
            self.delegate?.textField(textField, handlerSend: buttonSend, text: text!)
        }
        
        return true;
    }

    
    func setupGesture() {
    }
    
    @IBAction func handlerTextField() {
//        self.delegate?.textField(textField, handlerAttach: buttonAttach)
    }
    
    @IBAction func handlerButtonAttach() {
        self.delegate?.textField(textField, handlerAttach: buttonAttach)
    }

    @IBAction func handlerButtonSend() {
        let text = self.textField.text
        self.textField.text = ""
        if !text!.isEmpty {
            self.delegate?.textField(textField, handlerSend: buttonSend, text: text!)
        }
    }

}
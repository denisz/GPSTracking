//
//  AnswerHeaderView.swift
//  GPSTracking
//
//  Created by denis zaytcev on 7/29/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import UIKit

class AnswerMapHeaderView: UIView {
    var model: Answer?
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setupGesture()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setupGesture()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "AnswerMapHeaderView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func setupGesture() {
        
    }
    
    func setupView(model: Answer, modelUser: User) {
        
    }
}